import Cocoa
import WebKit

// Diagnóstico opcional: open -n DAZNer.app --args --debug  (escribe debug.log y habilita el inspector web)
let debugMode = CommandLine.arguments.contains("--debug")
let safariUA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
let homeURL = URL(string: "https://www.dazn.com/")!


// Intercepta el fullscreen de HTML5: en vez de pantalla completa de macOS, el elemento llena la ventana/panel
let fillScript = (#"""
(() => {
  if (window.__fillFS) return; window.__fillFS = true;
  const DEBUG = __DEBUG__;
  let cur = null, anc = [], hid = [], obs = null, savedStyle = null;
  const st = document.createElement('style');
  st.textContent = `
    .__fs{position:fixed!important;top:0!important;left:0!important;right:0!important;bottom:0!important;width:100vw!important;height:100vh!important;max-width:none!important;max-height:none!important;margin:0!important;z-index:2147483647!important;background:#000!important;transform:none!important}
    .__fsh{visibility:hidden!important}
    .__fsa{opacity:1!important;visibility:visible!important;transform:none!important;filter:none!important;perspective:none!important;contain:none!important;overflow:visible!important;clip-path:none!important;will-change:auto!important}
    video.__fs{object-fit:contain!important}`;
  (document.head || document.documentElement).appendChild(st);
  const dbg = o => { if (!DEBUG) return; try { o.top = window === top; webkit.messageHandlers.dbg.postMessage(JSON.stringify(o)); } catch (e) {} };
  const desc = e => e ? (e.tagName + '#' + e.id + '.' + String(e.className).slice(0, 70)) : 'null';
  const rc = e => { const r = e.getBoundingClientRect(); return [r.x|0, r.y|0, r.width|0, r.height|0].join(','); };
  if (DEBUG) {
    const pg = t => dbg({ev:'page:' + t, pane:window.__pane, w:innerWidth, h:innerHeight, href:location.pathname.slice(0, 60)});
    for (const t of ['resize', 'pagehide', 'beforeunload', 'DOMContentLoaded', 'load', 'visibilitychange']) addEventListener(t, () => pg(t), true);
    pg('script-start');
    // Mide el hueco entre celdas del multiview de DAZN (solo cuando cambia)
    let lastMv = '';
    setInterval(() => {
      const c = document.querySelector('[class*="multiview-container"]');
      if (!c) return;
      const cs = getComputedStyle(c);
      const o = {ev:'mvgap', vw:innerWidth + 'x' + innerHeight, dpr:devicePixelRatio, rect:rc(c), display:cs.display, gap:cs.gap, rowGap:cs.rowGap, colGap:cs.columnGap,
                 cols:cs.gridTemplateColumns, rows:cs.gridTemplateRows, pad:cs.padding,
                 kids:[...c.children].slice(0, 6).map(k => desc(k).slice(0, 40) + ' ' + rc(k)),
                 vids:[...c.querySelectorAll('video')].slice(0, 6).map(rc)};
      const j = JSON.stringify(o);
      if (j !== lastMv) { lastMv = j; dbg(o); }
    }, 3000);
  }
  const fire = (el) => {
    for (const n of ['fullscreenchange','webkitfullscreenchange']) {
      document.dispatchEvent(new Event(n, {bubbles:true}));
      if (el) el.dispatchEvent(new Event(n, {bubbles:true}));
    }
  };
  const exit = () => {
    if (!cur) return Promise.resolve();
    dbg({ev:'exit', stack:String(new Error().stack).slice(0, 500)});
    if (obs) { obs.disconnect(); obs = null; }
    const el = cur; cur = null;
    if (savedStyle === null) el.removeAttribute('style'); else el.setAttribute('style', savedStyle);
    el.classList.remove('__fs'); anc.forEach(a => a.classList.remove('__fsa')); anc = [];
    hid.forEach(h => h.classList.remove('__fsh')); hid = [];
    fire(el); return Promise.resolve();
  };
  const enter = function () {
    if (cur) exit();
    cur = this; this.classList.add('__fs');
    savedStyle = this.getAttribute('style');
    for (const [k, v] of [['margin', '0'], ['left', '0'], ['top', '0'], ['right', '0'], ['bottom', '0']]) this.style.setProperty(k, v, 'important');
    for (let a = this.parentElement; a; a = a.parentElement) { a.classList.add('__fsa'); anc.push(a); }
    // oculta todo lo que no sea el elemento ni sus ancestros (capas DRM de otros videos incluidas)
    for (let a = this; a && a !== document.documentElement; a = a.parentElement)
      for (const sib of a.parentElement ? a.parentElement.children : [])
        if (sib !== a && sib.tagName !== 'STYLE' && sib.tagName !== 'SCRIPT') { sib.classList.add('__fsh'); hid.push(sib); }
    // React/DAZN reescribe className al detectar el fullscreen y borra nuestras marcas: se reponen al vuelo
    const keep = [[cur, '__fs'], ...anc.map(a => [a, '__fsa']), ...hid.map(h => [h, '__fsh'])];
    const want = new Map(keep);
    obs = new MutationObserver(ms => { for (const m of ms) { const c = want.get(m.target); if (c && !m.target.classList.contains(c)) m.target.classList.add(c); } });
    keep.forEach(([e]) => obs.observe(e, {attributes:true, attributeFilter:['class']}));
    dbg({ev:'enter', el:desc(this), rect:rc(this), vw:innerWidth+'x'+innerHeight,
         chain:(() => { const c = []; for (let a = this.parentElement, i = 0; a && i < 8; a = a.parentElement, i++) c.push(desc(a) + '@' + rc(a)); return c; })(),
         videos:this.querySelectorAll('video').length, stack:String(new Error().stack).slice(0, 300)});
    if (DEBUG) setTimeout(() => {
      if (!cur) return dbg({ev:'after', note:'ya salio (cur null)'});
      const cs = getComputedStyle(cur), r = cur.getBoundingClientRect();
      dbg({ev:'after', el:desc(cur), rect:rc(cur), display:cs.display, vis:cs.visibility, op:cs.opacity, pos:cs.position, z:cs.zIndex,
           atCenter:desc(document.elementFromPoint(r.x + r.width / 2, r.y + r.height / 2)),
           videos:[...cur.querySelectorAll('video')].map(v => rc(v) + ' ' + getComputedStyle(v).display)});
    }, 500);
    if (DEBUG) setTimeout(() => {
      if (!cur) return;
      const dflt = {opacity:'1', maskImage:'none', backdropFilter:'none', isolation:'auto', mixBlendMode:'normal', clipPath:'none',
                    contain:'none', contentVisibility:'visible', transform:'none', filter:'none', overflow:'visible', zIndex:'auto', position:'static', visibility:'visible'};
      const dump = e => { const cs = getComputedStyle(e), d = {};
        for (const k in dflt) if (cs[k] !== dflt[k]) d[k] = String(cs[k]).slice(0, 40);
        return desc(e).slice(0, 50) + ' ' + rc(e) + ' ' + JSON.stringify(d); };
      const chain = []; for (let a = cur, i = 0; a && i < 12; a = a.parentElement, i++) chain.push(dump(a));
      const pts = [[.05,.05],[.5,.5],[.95,.05],[.05,.95],[.95,.95],[.5,.02]].map(([x, y]) => {
        const e = document.elementFromPoint(innerWidth * x, innerHeight * y);
        return x + ',' + y + ':' + (e ? (cur.contains(e) ? 'DENTRO ' : 'FUERA ') + desc(e).slice(0, 60) : 'null'); });
      const vids = [...cur.querySelectorAll('video')].map(v => ({paused:v.paused, rs:v.readyState, vw:v.videoWidth + 'x' + v.videoHeight, t:v.currentTime|0, style:v.getAttribute('style')}));
      const kids = [...cur.children].slice(0, 8).map(k => { const cs = getComputedStyle(k);
        return desc(k).slice(0, 60) + ' ' + rc(k) + ' style=' + (k.getAttribute('style') || '') + ' pos=' + cs.position + ' ml=' + cs.marginLeft + ' left=' + cs.left + ' tr=' + cs.transform; });
      const ccs = getComputedStyle(cur);
      dbg({ev:'grid', kids, curCss:{display:ccs.display, cols:ccs.gridTemplateColumns, rows:ccs.gridTemplateRows, pl:ccs.paddingLeft, ml:ccs.marginLeft, left:ccs.left, w:ccs.width, tr:ccs.transform}});
      // [desactivado] Qué hay justo en el margen derecho e inferior: elemento y color de fondo de cada ancestro hasta el que está en pantalla completa
      // const edge = [[innerWidth - 2, innerHeight / 2], [innerWidth / 2, innerHeight - 2]].map(([x, y]) => {
      //   const out = []; for (let e = document.elementFromPoint(x, y), i = 0; e && i < 14; e = e.parentElement, i++) {
      //     const cs = getComputedStyle(e); out.push(desc(e).slice(0, 44) + ' ' + rc(e) + ' bg=' + cs.backgroundColor + (cs.backgroundImage !== 'none' ? ' img' : ''));
      //     if (e === cur) break; }
      //   return (x | 0) + ',' + (y | 0) + ' => ' + out.join(' < '); });
      // dbg({ev:'edge', edge, vv:[...cur.querySelectorAll('video')].map(v => { const c = getComputedStyle(v); return rc(v) + ' fit=' + c.objectFit + ' m=' + c.margin + ' bg=' + c.backgroundColor; })});
      dbg({ev:'deep', chain, pts, vids, curStyle:cur.getAttribute('style'), curClass:String(cur.className).slice(-120)});
    }, 1200);
    fire(this); return Promise.resolve();
  };
  for (const n of ['requestFullscreen','webkitRequestFullscreen','webkitRequestFullScreen'])
    Element.prototype[n] = enter;
  for (const n of ['exitFullscreen','webkitExitFullscreen','webkitCancelFullScreen'])
    document[n] = exit;
  const def = (k, g) => { try { Object.defineProperty(document, k, {get:g, configurable:true}); } catch (e) {} };
  def('fullscreenElement', () => cur); def('webkitFullscreenElement', () => cur);
  def('webkitCurrentFullScreenElement', () => cur);
  def('fullscreenEnabled', () => true); def('webkitFullscreenEnabled', () => true);
  def('webkitIsFullScreen', () => !!cur); def('fullscreen', () => !!cur);
  addEventListener('keydown', e => { if (e.key === 'Escape' && cur) exit(); }, true);
})();
"""#).replacingOccurrences(of: "__DEBUG__", with: debugMode ? "true" : "false")

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
        cfg.userContentController.addUserScript(WKUserScript(source: fillScript, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        let p = Pane(frame: .zero, configuration: cfg)
        p.customUserAgent = safariUA
        if debugMode {
            p.configuration.userContentController.addUserScript(WKUserScript(source: "window.__pane = \(i);", injectionTime: .atDocumentStart, forMainFrameOnly: true))
        }
        p.isInspectable = debugMode
        p.uiDelegate = self
        p.allowsBackForwardNavigationGestures = true
        p.onFocus = { [weak self] in self?.focus(i) }
        p.load(URLRequest(url: homeURL))
        return p
    }

    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.setActivationPolicy(.regular)
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
