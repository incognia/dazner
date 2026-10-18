## Context

Hoy el script de pantalla completa está dentro de `macos/DAZNer.swift` como una cadena de texto cruda de Swift. El modo de diagnóstico se enciende reemplazando la marca `__DEBUG__` por `true` o `false` al construir esa cadena, y el registro usa `webkit.messageHandlers.dbg`, que solo existe en WebKit. El panel se identifica con otro script pequeño que define `window.__pane`.

## Goals / Non-Goals

**Goals:**

- Un solo archivo JavaScript que sirva en WebKit, WebView2, Qt WebEngine y WebKitGTK.
- Que las plataformas solo aporten dos puentes: cómo se carga el script y cómo llegan los mensajes de registro.
- Cero cambios de comportamiento en macOS.

**Non-Goals:**

- Cambiar la lógica de pantalla completa o el CSS que inyecta.
- Minificar o empaquetar el script con herramientas de compilación de JavaScript.

## Decisions

- **Ubicación:** `shared/fill-fullscreen.js`. En macOS, `macos/build.sh` lo copia a `macos/DAZNer.app/Contents/Resources/fill-fullscreen.js`, y esa copia se ignora en git porque es un artefacto generado.
- **Diagnóstico:** la plataforma define `window.__daznerDebug = true|false` con un script de usuario previo, en lugar de reemplazar texto dentro del archivo. Así el archivo es idéntico en todas las versiones.
- **Registro:** el script llama a `window.__daznerLog(mensaje)` solo si existe. En macOS, un script previo la define como `m => webkit.messageHandlers.dbg.postMessage(m)`, y solo en modo de diagnóstico.
- **Identificador de panel:** se mantiene `window.__pane`, definido por la plataforma, y solo se usa en el diagnóstico.
- **Orden de carga:** primero las variables de la plataforma (`__daznerDebug`, `__daznerLog`, `__pane`) y después el script compartido, para que los lea desde el inicio.

## Risks / Trade-offs

- **Regresión en macOS:** al mover el código puede romperse algo sutil. Se mitiga con una lista de verificación manual en macOS (tareas 3.x) antes de dar el cambio por bueno.
- **Fallo si falta el archivo en el paquete:** si `build.sh` no copia el script, la pantalla completa no se emula. Se mitiga con una tarea que lo verifica y con un mensaje claro al arrancar si el archivo no está.

## Open Questions

Ninguna que cambie lo que se construye.
