## Context

La versión de macOS usa `WKWebView` y FairPlay. En Linux, DAZN funciona en Chrome con Widevine, pero WebKitGTK es otro motor: no trae un módulo de DRM comercial utilizable y no puede cargar el Widevine de Chrome. Por eso esta es la variante experimental, y la prueba de reproducción manda sobre todo lo demás.

## Goals / Non-Goals

**Goals:**

- Saber con certeza, con una prueba mínima, si DAZN reproduce en WebKitGTK.
- Si reproduce, mismo comportamiento que macOS con las excepciones por servidor gráfico documentadas.

**Non-Goals:**

- Hacer que reproduzca eludiendo protecciones o redistribuyendo módulos de DRM.
- Empaquetado, y cualquier trabajo en Qt.

## Decisions

- **Lenguaje:** Vala/C, el estilo de GNOME: la aplicación en Vala y C solo para lo que Vala no cubra, ya que Vala compila a C. Su sintaxis, muy parecida a la de C#, permite trasladar casi directo la lógica de la versión de Windows.
- **Enlaces disponibles:** el repositorio de Vala trae `webkitgtk-6.0.vapi`, `gtk4.vapi` y `libsoup-3.0.vapi` (verificado el 18 de octubre de 2026), así que no hay que generar nada.
- **Biblioteca:** GTK4 con WebKitGTK 6.0, compilado con Meson.
- **Paneles:** dos vistas web en una caja horizontal con un hueco de 8 px; la segunda se crea al elegir dos paneles y se destruye al volver a uno.
- **Audio por foco:** silenciar la vista sin foco con la propiedad de silencio de WebKitGTK.
- **Sesión:** una sesión de red con almacenamiento persistente propio, compartida entre paneles e instancias.
- **Ventana sin bordes:** decoraciones desactivadas, arrastre y redimensionado con las llamadas del sistema de ventanas de GTK.
- **Script compartido:** se define `window.__daznerDebug`, `window.__daznerLog` y `window.__pane` antes, y el registro llega por el gestor de mensajes de WebKitGTK.
- **Alternativa descartada por ahora:** Rust con el *crate* `webkit6`, compatible con `gtk4`. Sigue siendo viable si se cambia de opinión.

## Risks / Trade-offs

- **DRM:** se espera que falle. La prueba lo decide y el cambio termina ahí si falla.
- **Wayland:** no hay posicionamiento ni restricción de proporción; se documenta como limitación.
- **Esfuerzo desperdiciado:** se evita construyendo la interfaz solo si la prueba pasa.

## Open Questions

- ¿Existe alguna forma legítima de que WebKitGTK cargue un módulo de DRM? Si la prueba falla, se investiga solo si se decide continuar; no se asume.
