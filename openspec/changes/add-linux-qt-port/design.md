## Context

La versión de macOS usa `WKWebView` y FairPlay. En Linux, DAZN funciona en Chrome con Widevine, y Qt WebEngine es Chromium incrustado en Qt, por lo que comparte motor con Chrome. Qt WebEngine no incluye Widevine: hay que indicarle el módulo de una instalación de Chrome. Además, la compilación de Chromium dentro de Qt puede venir sin códecs propietarios, que DAZN necesita.

## Goals / Non-Goals

**Goals:**

- Mismo comportamiento que macOS, medido con los escenarios de las especificaciones neutrales y con las excepciones por servidor gráfico documentadas.
- Reproducir con el DRM del sistema sin redistribuir ningún módulo.

**Non-Goals:**

- Empaquetado, y cualquier trabajo en GTK.
- Reescribir el script de pantalla completa: se usa el compartido.

## Decisions

- **Lenguaje:** C++/QML, el estilo de KDE: la interfaz en QML (Qt Quick y el tipo `WebEngineView`) sobre un núcleo mínimo en C++. El `main.cpp` arranca el motor de QML y cubre lo que QML no alcance, como la geometría de pantalla para rellenar y centrar.
- **Compilación:** CMake, con Qt 6.
- **Qué cubre QML sin código extra:** `userScripts` para el script compartido, `audioMuted` por panel, un perfil con almacenamiento persistente para la sesión, y `startSystemMove` y `startSystemResize` para mover y redimensionar una ventana sin bordes. Esto se confirma en la prueba.
- **Widevine:** se pasa la ruta del módulo de Chrome al motor mediante una bandera de Chromium al arrancar, buscando en las ubicaciones habituales de Chrome. No se incluye en el repositorio.
- **Paneles:** dos `WebEngineView` en una fila con un hueco de 8 px; el segundo se crea al elegir dos paneles y se destruye al volver a uno.
- **Proporción fija en Wayland:** corregir el tamaño en el manejador de redimensionado, porque el protocolo no ofrece una restricción de proporción.
- **Script compartido:** se define `window.__daznerDebug`, `window.__daznerLog` y `window.__pane` antes, y el registro llega por el canal de mensajes de Qt WebEngine.

## Risks / Trade-offs

- **Códecs propietarios:** algunas compilaciones de Qt WebEngine no los incluyen. La prueba de la tarea 1.2 lo comprueba antes de seguir.
- **Calidad de Widevine en Linux:** suele limitarse a un nivel de seguridad bajo, así que la calidad máxima puede ser menor que en macOS. Se mide y se documenta.
- **Wayland:** no hay posicionamiento ni restricción de proporción; se documenta como limitación.
- **Dependencia de Chrome:** sin Chrome instalado no hay Widevine. Se documenta como requisito y la aplicación avisa.

## Open Questions

- ¿Qué origen de Qt WebEngine con códecs usar (paquete de la distribución, instalador de Qt u otro)? Cambia las instrucciones del README y se resuelve en la tarea 1.2.
- ¿Empaquetado como AppImage o Flatpak? Fuera del alcance de este cambio.
