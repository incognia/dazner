import Cocoa
import WebKit

// Diagnóstico opcional: open -n DAZNer.app --args --debug  (escribe debug.log y habilita el inspector web)
let debugMode = CommandLine.arguments.contains("--debug")
let safariUA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
let homeURL = URL(string: "https://www.dazn.com/")!


// Script compartido de pantalla completa: macos/build.sh lo copia al paquete desde
// shared/fill-fullscreen.js. En el paquete solo existe esa copia, nunca una versión propia de macOS.
let fillScript: String? = Bundle.main.url(forResource: "fill-fullscreen", withExtension: "js")
    .flatMap { try? String(contentsOf: $0, encoding: .utf8) }

// Puente de macOS: define los ganchos que el script compartido lee. Se inyecta antes que el script.
let platformBridge: String = {
    var s = "window.__daznerDebug = \(debugMode ? "true" : "false");"
    if debugMode {
        s += " window.__daznerLog = function (m) { try { window.webkit.messageHandlers.dbg.postMessage(m); } catch (e) {} };"
    }
    return s
}()

final class DebugLog: NSObject, WKScriptMessageHandler {
    // junto a la app: <carpeta>/debug.log
    let path = Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent("debug.log").path
    func userContentController(_ c: WKUserContentController, didReceive m: WKScriptMessage) {
        let line = "[\(Date())] \(m.body)\n"
        if let h = FileHandle(forWritingAtPath: path) { h.seekToEndOfFile(); h.write(line.data(using: .utf8)!); try? h.close() }
        else { try? line.write(toFile: path, atomically: true, encoding: .utf8) }
    }
}
let debugLog = DebugLog()

final class Pane: WKWebView {
    var onFocus: (() -> Void)?
    override func mouseDown(with event: NSEvent) {
        onFocus?()
        super.mouseDown(with: event)
    }
}

final class Grid: NSView {
    // Hueco visible entre videos en el multiview de DAZN: 4 px de la cuadrícula + 2 px de borde por celda a cada lado
    static let gap: CGFloat = 8

    var panes: [Pane] = []
    var count = 1 { didSet { needsLayout = true } }

    override func layout() {
        super.layout()
        let n = min(count, panes.count)
        for (i, p) in panes.enumerated() { p.isHidden = i >= n }
        guard n > 0 else { return }
        let g = Grid.gap
        let cols = n == 1 ? 1 : 2
        let rows = (n + cols - 1) / cols
        // El hueco va dentro del tamaño de la ventana, así que la proporción de la ventana (32:9) no cambia
        let w = (bounds.width - g * CGFloat(cols - 1)) / CGFloat(cols)
        let h = (bounds.height - g * CGFloat(rows - 1)) / CGFloat(rows)
        for i in 0..<n {
            let r = i / cols, c = i % cols
            // la última celda ocupa todo el ancho si queda sola en su fila (3 paneles)
            let lastAlone = (i == n - 1) && (n % cols == 1) && cols > 1
            let fw = lastAlone ? bounds.width : w
            panes[i].frame = NSRect(x: CGFloat(c) * (w + g), y: bounds.height - CGFloat(r + 1) * h - CGFloat(r) * g, width: fw, height: h)
        }
    }
}

// Franja invisible superior: arrastrar desde aquí mueve la ventana
final class DragStrip: NSView {
    override func mouseDown(with e: NSEvent) { window?.performDrag(with: e) }
    override func mouseUp(with e: NSEvent) { if e.clickCount == 2 { window?.zoom(nil) } }
}

final class Win: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
    // Option + arrastrar mueve la ventana
    override func sendEvent(_ e: NSEvent) {
        if e.type == .leftMouseDown, e.modifierFlags.contains(.option) { performDrag(with: e); return }
        super.sendEvent(e)
    }
}

final class App: NSObject, NSApplicationDelegate, WKUIDelegate {
    var win: Win!
    let grid = Grid()
    var focused = 0
    var timer: Timer?

    func makePane(_ i: Int) -> Pane {
        let cfg = WKWebViewConfiguration()
        cfg.websiteDataStore = .default()
        cfg.mediaTypesRequiringUserActionForPlayback = []
        cfg.preferences.isElementFullscreenEnabled = true
        if debugMode { cfg.userContentController.add(debugLog, name: "dbg") }
        // Orden de carga: primero las variables de la plataforma y al final el script compartido, que las lee al arrancar
        cfg.userContentController.addUserScript(WKUserScript(source: platformBridge, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        if debugMode {
            cfg.userContentController.addUserScript(WKUserScript(source: "window.__pane = \(i);", injectionTime: .atDocumentStart, forMainFrameOnly: true))
        }
        if let script = fillScript {
            cfg.userContentController.addUserScript(WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        }
        let p = Pane(frame: .zero, configuration: cfg)
        p.customUserAgent = safariUA
        p.isInspectable = debugMode
        p.uiDelegate = self
        p.allowsBackForwardNavigationGestures = true
        p.onFocus = { [weak self] in self?.focus(i) }
        p.load(URLRequest(url: homeURL))
        return p
    }

    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.setActivationPolicy(.regular)
        if fillScript == nil {
            FileHandle.standardError.write(Data("Falta fill-fullscreen.js en el paquete; la pantalla completa no se emulará. Compila con macos/build.sh.\n".utf8))
            let alert = NSAlert()
            alert.messageText = "Falta fill-fullscreen.js en el paquete"
            alert.informativeText = "La pantalla completa de DAZN no se emulará. Compila con macos/build.sh, que copia shared/fill-fullscreen.js al paquete."
            alert.runModal()
        }
        grid.panes = [makePane(0)]   // el panel 2 se crea al vuelo con ⌘2
        // grid.panes = (0..<4).map(makePane)   // 3 y 4 paneles: desactivados por ahora
        grid.count = 1

        win = Win(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 720),
                  styleMask: [.titled, .fullSizeContentView, .resizable, .miniaturizable, .closable],
                  backing: .buffered, defer: false)
        win.contentView = grid
        grid.panes.forEach { grid.addSubview($0) }
        win.titlebarAppearsTransparent = true
        [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton].forEach { win.standardWindowButton($0)?.isHidden = true }
        let strip = DragStrip(frame: NSRect(x: 0, y: grid.bounds.height - 14, width: grid.bounds.width, height: 14))
        strip.autoresizingMask = [.width, .minYMargin]
        grid.addSubview(strip)
        win.titleVisibility = .hidden
        win.isMovableByWindowBackground = true
        win.appearance = NSAppearance(named: .darkAqua)
        win.backgroundColor = .black
        win.hasShadow = true
        win.contentAspectRatio = NSSize(width: 16, height: 9)
        win.center()
        win.makeKeyAndOrderFront(nil)
        buildMenu()
        focus(0)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.syncAudio() }
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { true }

    // Solo el panel con foco suena
    func focus(_ i: Int) {
        focused = i
        win.makeFirstResponder(grid.panes[i])
        syncAudio(unmuteFocused: grid.count > 1)
    }

    // El temporizador solo silencia los paneles sin foco; nunca reactiva el audio del enfocado
    func syncAudio(unmuteFocused: Bool = false) {
        for (i, p) in grid.panes.enumerated() where !p.isHidden {
            if i == focused {
                if unmuteFocused { p.evaluateJavaScript("document.querySelectorAll('video').forEach(v=>v.muted=false)", completionHandler: nil) }
            } else {
                p.evaluateJavaScript("document.querySelectorAll('video').forEach(v=>v.muted=true)", completionHandler: nil)
            }
        }
    }

    // target=_blank y similares se abren en el mismo panel
    func webView(_ w: WKWebView, createWebViewWith c: WKWebViewConfiguration, for a: WKNavigationAction, windowFeatures f: WKWindowFeatures) -> WKWebView? {
        if a.targetFrame == nil { w.load(a.request) }
        return nil
    }

    // MARK: menú / atajos

    @objc func layoutN(_ s: NSMenuItem) {
        let n = s.tag
        guard n != grid.count else { return }
        let wasFocused = focused
        if n > grid.count {
            // Crea el panel que falte (debajo de la franja de arrastre, que debe quedar encima)
            while grid.panes.count < n {
                let p = makePane(grid.panes.count)
                grid.panes.append(p)
                grid.addSubview(p, positioned: .below, relativeTo: grid.subviews.last { $0 is DragStrip })
            }
        } else {
            // Mata los paneles sobrantes para liberar memoria: detiene la carga, suelta delegados y quita la vista
            while grid.panes.count > n {
                let p = grid.panes.removeLast()
                p.stopLoading()
                p.uiDelegate = nil
                p.removeFromSuperview()
            }
        }
        grid.count = n
        // Primero la ventana y luego el layout, para que el panel que ya estaba abierto no cambie de tamaño
        // (un cambio de tamaño intermedio hace que DAZN rehaga el reproductor).
        resizeWindow(forPanes: n)
        if focused >= n { focus(0) }
        // Si el panel que queda estaba silenciado por no tener foco, se reactiva su audio
        if n == 1 && wasFocused != 0 { syncAudio(unmuteFocused: true) }
    }

    // Rellenar y centrar: el rectángulo más grande que cabe en la pantalla con la proporción actual, centrado.
    @objc func fillCenter() {
        let vf = (win.screen ?? NSScreen.main)?.visibleFrame ?? win.frame
        let r = win.contentAspectRatio
        // La franja de título transparente suma alto al marco pero no al contenido: se descuenta para respetar la proporción
        let bar = win.frame.height - win.contentRect(forFrameRect: win.frame).height
        let cw = min(vf.width, (vf.height - bar) * r.width / r.height)
        let ch = cw * r.height / r.width
        let size = NSSize(width: cw, height: ch + bar)
        let origin = NSPoint(x: vf.midX - size.width / 2, y: vf.midY - size.height / 2)
        win.setFrame(NSRect(origin: origin, size: size), display: true, animate: true)
    }

    // 1 panel = 16:9; 2 paneles = 32:9 (dos 16:9 lado a lado). El fullscreen de DAZN queda dentro de cada panel.
    func resizeWindow(forPanes n: Int) {
        let ratio = NSSize(width: 16 * n, height: 9)
        let old = win.frame
        let maxW = (win.screen ?? NSScreen.main)?.visibleFrame.width ?? old.width
        let w = min(max(old.width * (n == 2 ? 2 : 0.5), 640), maxW)
        let h = w * ratio.height / ratio.width
        win.contentAspectRatio = ratio
        // conserva la esquina superior izquierda
        win.setFrame(NSRect(x: old.minX, y: old.maxY - h, width: w, height: h), display: false, animate: false)
    }
    @objc func reload() { grid.panes[focused].reload() }
    @objc func home() { grid.panes[focused].load(URLRequest(url: homeURL)) }
    @objc func toggleFloat() { win.level = win.level == .floating ? .normal : .floating }
    @objc func toggleShadow() { win.hasShadow.toggle() }
    @objc func nextPane() { focus((focused + 1) % grid.count) }
    @objc func closeWin() { win.close() }

    @objc func openURL() {
        let a = NSAlert()
        a.messageText = "Abrir URL en el panel \(focused + 1)"
        let t = NSTextField(frame: NSRect(x: 0, y: 0, width: 420, height: 24))
        t.stringValue = grid.panes[focused].url?.absoluteString ?? ""
        a.accessoryView = t
        a.addButton(withTitle: "Abrir"); a.addButton(withTitle: "Cancelar")
        a.window.initialFirstResponder = t
        guard a.runModal() == .alertFirstButtonReturn else { return }
        var s = t.stringValue.trimmingCharacters(in: .whitespaces)
        if !s.contains("://") { s = "https://" + s }
        if let u = URL(string: s) { grid.panes[focused].load(URLRequest(url: u)) }
    }

    func buildMenu() {
        let main = NSMenu()
        func add(_ title: String, _ items: [(String, Selector, String, Int)]) {
            let top = NSMenuItem(); main.addItem(top)
            let m = NSMenu(title: title); top.submenu = m
            for (t, sel, key, tag) in items {
                let it = NSMenuItem(title: t, action: sel, keyEquivalent: key)
                it.tag = tag
                // terminate: lo atiende NSApplication; con target propio el ítem queda deshabilitado
                it.target = sel == #selector(NSApplication.terminate(_:)) ? nil : self
                m.addItem(it)
            }
        }
        add("DAZNer", [("Salir", #selector(NSApplication.terminate(_:)), "q", 0)])
        add("Ventana", [
            ("Abrir URL…", #selector(openURL), "l", 0),
            ("Recargar", #selector(reload), "r", 0),
            ("Inicio de DAZN", #selector(home), "h", 0),
            ("1 panel", #selector(layoutN), "1", 1),
            ("2 paneles", #selector(layoutN), "2", 2),
            // ("3 paneles", #selector(layoutN), "3", 3),   // desactivado por ahora
            // ("4 paneles", #selector(layoutN), "4", 4),   // desactivado por ahora
            ("Siguiente panel (audio)", #selector(nextPane), "\t", 0),
            ("Rellenar y centrar", #selector(fillCenter), "f", 0),
            ("Siempre encima", #selector(toggleFloat), "t", 0),
            ("Sombra", #selector(toggleShadow), "s", 0),
            ("Cerrar", #selector(closeWin), "w", 0),
        ])
        // Menú Edición: sin él no funcionan ⌘C/⌘V/⌘X/⌘A/⌘Z en los campos web
        let editTop = NSMenuItem(); main.addItem(editTop)
        let edit = NSMenu(title: "Edición"); editTop.submenu = edit
        for (t, sel, key) in [("Deshacer", Selector(("undo:")), "z"), ("Cortar", #selector(NSText.cut(_:)), "x"),
                              ("Copiar", #selector(NSText.copy(_:)), "c"), ("Pegar", #selector(NSText.paste(_:)), "v"),
                              ("Seleccionar todo", #selector(NSText.selectAll(_:)), "a")] {
            edit.addItem(NSMenuItem(title: t, action: sel, keyEquivalent: key))
        }
        // Cmd+Tab del sistema está tomado, así que el atajo de panel es Cmd+`
        main.items[1].submenu?.items.first { $0.title.hasPrefix("Siguiente") }?.keyEquivalent = "`"
        NSApp.mainMenu = main
    }
}

let app = NSApplication.shared
let delegate = App()
app.delegate = delegate
app.run()
