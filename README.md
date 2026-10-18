---
title: "DAZNer"
description: "Visor nativo y mínimo de DAZN (NFL Game Pass) para macOS con WebKit: ventana sin bordes, dos paneles y pantalla completa dentro de la ventana."
---

# DAZNer

*Última modificación: 18 de octubre de 2026, 13:47 (CST)*

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.html)
[![Platform: macOS](https://img.shields.io/badge/platform-macOS-lightgrey.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-F05138?logo=swift&logoColor=white)](https://www.swift.org/)
[![WebKit](https://img.shields.io/badge/WebKit-WKWebView-informational.svg)](https://webkit.org/)

Visor nativo y mínimo de DAZN (NFL Game Pass) para macOS, hecho con WebKit. Muestra los partidos en una ventana sin bordes, ideal para pantallas grandes y para usarla junto al *multiview* de DAZN. Proyecto personal de Rodrigo Álvarez (@incognia).

## Por qué WebKit

- DAZN usa DRM. WebKit reproduce con FairPlay igual que Safari, sin configuración adicional.
- Es un solo archivo de Swift que se compila con `swiftc`, sin Xcode y sin dependencias.

## Compilar

```bash
swiftc -O DAZNer.swift -o DAZNer.app/Contents/MacOS/DAZNer
codesign --force --sign - DAZNer.app
open -n DAZNer.app
```

Para regenerar el ícono a partir de `assets/icon.png`:

```bash
swiftc scripts/make-icon.swift -o /tmp/make-icon
/tmp/make-icon assets/icon.png DAZNer.app/Contents/Resources/app.icns
```

## Uso

- **Mover la ventana:** arrastra desde la franja invisible del borde superior (14 px) o mantén ⌥ Option y arrastra desde cualquier punto. El doble clic en la franja maximiza o restaura.
- **Redimensionar:** desde los bordes, con proporción fija (16:9 con un panel, 32:9 con dos).
- **Rellenar y centrar:** ⌘F agranda la ventana al máximo que cabe en la pantalla sin perder la proporción y la centra.
- **Paneles:** ⌘1 un panel, ⌘2 dos paneles, con un hueco de 8 px entre ellos como en el *multiview* de DAZN. El segundo se crea al elegirlo y se cierra al volver a un panel, para liberar memoria.
- **Pantalla completa:** el botón de pantalla completa de DAZN llena la ventana o el panel en lugar de pasar a la pantalla completa de macOS. Esc regresa al modo normal.
- **Atajos:** ⌘L abre una URL en el panel con foco, ⌘R recarga, ⌘H vuelve al inicio de DAZN, ⌘` cambia el panel con audio, ⌘T deja la ventana siempre encima, ⌘W cierra y ⌘Q sale.
- **Varias instancias:** `open -n DAZNer.app` abre otra ventana independiente. Comparten la misma sesión.

## Modo de diagnóstico

```bash
open -n DAZNer.app --args --debug
```

Escribe `debug.log` junto a la aplicación con los eventos de pantalla completa y de cada panel, y habilita el inspector web de Safari. Está desactivado de forma predeterminada.

## Notas

- DAZNer es un proyecto no oficial y no está afiliado a DAZN ni a la NFL. Consulta `NOTICE.md`.
- La contraseña no se guarda. Solo se conserva la sesión de DAZN, en `~/Library/WebKit/mx.org.faraday.dazner`. El identificador de la aplicación es `mx.org.faraday.dazner` (el dominio faraday.org.mx al revés).
- Cambiar el tamaño de la ventana hace que DAZN rehaga el reproductor y refresque el panel. Conviene dejar la ventana en el tamaño deseado antes de abrir el segundo panel.
- El límite de reproducción de DAZN depende de la ubicación (red) y no del número de ventanas.
- La aplicación está firmada solo de forma local. Si macOS la bloquea, ábrela con clic derecho → Abrir.
- Las opciones de 3 y 4 paneles están comentadas en el código para reutilizarlas después.

## Licencia

DAZNer es software libre y se distribuye bajo la licencia GPLv3. Consulta el texto completo en [LICENSE](LICENSE) y el aviso de proyecto no oficial y de marcas en [NOTICE.md](NOTICE.md).

<!-- licence:start -->

---

*Este proyecto fue elaborado por Rodrigo Álvarez (@incognia) y se distribuye bajo la licencia GPLv3. Para más detalles, consulta el archivo LICENSE.*

*Copyright © 2026, Rodrigo Ernesto Álvarez Aguilera. Este es software libre bajo los términos de la GNU General Public License v3.*

<!-- licence:end -->
