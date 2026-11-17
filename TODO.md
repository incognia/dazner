# Pendientes

*Última modificación: 16 de noviembre de 2026, 21:53 (CST)*

Vista corta de lo que falta, por orden de ejecución y por máquina. El detalle de cada tarea (con su verificación) está en `openspec/changes/<cambio>/tasks.md`, y el orden completo y sus dependencias, en la sección «Orden de ejecución» de `ROADMAP.md`. Si este archivo y OpenSpec discrepan, manda OpenSpec.

## Ahora, en paralelo

Estas pruebas no dependen entre sí y deciden si se sigue con cada versión. La de Windows ya se hizo y pasó.

### En Windows (git, compilación y pruebas desde Windows nativo)

- [x] **Prueba de reproducción** (`add-windows-port`, tareas 1.1 y 1.2): proyecto WPF mínimo con WebView2 que abra DAZN, compilado con `dotnet build` en PowerShell y con Visual Studio; iniciar sesión y reproducir un partido. Hecha y superada: DAZN reproduce dentro de WebView2 con Widevine.

### En Linux

- [ ] **Prueba de reproducción con Qt** (`add-linux-qt-port`, tareas 1.1 y 1.2): proyecto mínimo de QML con `WebEngineView` y el módulo Widevine de Chrome; comprobar que el Qt WebEngine usado incluye los códecs propietarios y reproducir un partido. **Si no reproduce, detenerse y documentar la causa.**
- [ ] **Prueba de reproducción con GTK** (`add-linux-gtk-port`, tareas 1.1 y 1.2): aplicación mínima en Vala con WebKitGTK 6.0. Se espera que falle por el DRM; si falla, documentarlo y cerrar la variante.

## Después, según los resultados

- [ ] **Anotar los resultados** de las pruebas de Qt y GTK en el `design.md` de cada cambio y en `ROADMAP.md`, y decidir qué versiones siguen. El de Windows ya está anotado.
- [x] **Terminar Windows** (`add-windows-port`, grupos 2 a 5): ventana, paneles, pantalla completa, sesión, atajos, paquete y paridad. Hecho: las 18 tareas verificadas, cambio archivado el 16 de noviembre de 2026.
- [ ] **Terminar Qt** (`add-linux-qt-port`, grupos 2 a 5, 14 tareas): lo mismo, con las limitaciones de Wayland. Requiere que la prueba pase.
- [ ] **Terminar GTK** (`add-linux-gtk-port`, grupos 2 a 5, 13 tareas), solo si la prueba de GTK pasa.

Prioridad si hay que elegir: Windows, luego Qt, luego GTK.

## Al final

- [ ] **Paridad, empaquetado y CI (fase 4):** tabla de funciones con el estado real de cada plataforma, GitHub Actions con una matriz por sistema, artefactos por versión, íconos `.ico` y PNG generados desde `shared/assets/icon.png` y un solo número de versión. Todavía no tiene cambio de OpenSpec: se propone con `/opsx:propose` al llegar aquí.
- [ ] **Archivar cada cambio terminado** con `/opsx:archive` y registrarlo con `/changelogger` y `/commit`.
- [ ] **Actualizar el README** con el estado, los requisitos y la compilación de cada plataforma nueva.

## Pendientes encontrados en la revisión

Salieron de la revisión del 7 de noviembre de 2026. Se atienden en un cambio propio y se verifican en la plataforma que se indica.

### En macOS

- [ ] **La ventana puede salirse de la pantalla al abrir el segundo panel:** `resizeWindow` duplica el ancho y conserva `minX`, así que la ventana cerca del borde derecho queda a medias fuera. Recorrerla a la izquierda solo cuando no quepa, sin cambiar su tamaño. Verificar con ⌘2 y la ventana pegada al borde derecho.
- [ ] **`Info.plist` permite HTTP sin cifrar** (`NSAllowsArbitraryLoads`) aunque DAZN usa solo HTTPS, y no declara `LSMinimumSystemVersion`, aunque `isInspectable` exige macOS 13.3. Verificar que DAZN inicia sesión y reproduce sin esa excepción.

### En Windows, vigilar en la pantalla completa (grupo 4 de `add-windows-port`, ya archivado)

Ninguno de los dos se ha observado en las pruebas del grupo 4.

- [ ] **`fill-fullscreen.js` dispara `fullscreenchange` dos veces en `document`:** una directa y otra que sube desde el elemento. WebKit lo tolera; comprobar que Chromium (WebView2) también.
- [ ] **El `MutationObserver` del *script* vigila `class` pero no `style`:** si React reescribe el estilo en línea, se pierden los márgenes con `!important`. Es la primera sospecha si reaparece el margen del *multiview*. Cualquier cambio al *script* exige repetir la verificación en macOS.

### Pendientes que dejó la revisión de Windows

- [ ] **El hueco del *multiview* en macOS:** en Windows mide 13 px en horizontal y 10 px en vertical con cuatro videos, y `AGENTS.md` anota 8 px, medidos en macOS. Comparar en macOS; probablemente viene de la cuadrícula de DAZN y no de la versión de Windows.
- [ ] **El límite de la ventana en un monitor de 1920 px:** una ventana de 1280 px no puede crecer al doble y el panel 1 baja de 1280 a 956 px, el ancho al que DAZN oculta el botón MultiView. macOS usa la misma fórmula con el mismo límite; decidir si se documenta o se corrige en las dos.

## Preguntas abiertas

- ¿Distribuir la versión de Windows como carpeta comprimida o como MSIX? Hoy se compila con .NET 10 y no necesita instalador.
- ¿Qué origen de Qt WebEngine con códecs propietarios usar en Linux (paquete de la distribución, instalador de Qt u otro)?
- ¿AppImage o Flatpak para Linux?
- ¿Qué calidad máxima da WebView2 frente a Chrome, y Widevine en Linux frente a macOS? Lo miden las pruebas de reproducción.

## Hecho

- [x] Versión de macOS con WebKit: ventana sin bordes, proporción fija, dos paneles, pantalla completa dentro de la ventana, rellenar y centrar, sesión persistente y modo `--debug`.
- [x] Reorganización del repositorio por plataforma (fase 0): `macos/`, `shared/` y `macos/build.sh`.
- [x] Licencia GPLv3, aviso de marcas, ícono propio e imagen de vista previa.
- [x] Hoja de ruta, con los lenguajes nativos por plataforma y los datos confirmados sobre el DRM.
- [x] OpenSpec: siete especificaciones base de macOS y cuatro cambios propuestos.
- [x] `AGENTS.md` y `.editorconfig`.
- [x] `.gitattributes` con finales de línea fijos (LF, y CRLF en `.sln`, `.bat` y `.cmd`), sin importar `core.autocrlf`: Git de Windows trae `core.autocrlf=true` y reescribía los archivos en CRLF.
- [x] Extracción del *script* de pantalla completa a `shared/fill-fullscreen.js` (fase 1): macOS lo carga desde el paquete y se verificó con el modo `--debug`.
- [x] Versión de Windows (`add-windows-port`): WPF con WebView2, 18 de 18 tareas verificadas, integrada en `main` el 16 de noviembre de 2026 y archivada.
