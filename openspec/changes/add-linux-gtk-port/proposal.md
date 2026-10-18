# Proposal

## Why

GTK con WebKitGTK es la forma nativa de GNOME de mostrar contenido web, y completaría la oferta de Linux. Sin embargo, es la variante con más riesgo: WebKitGTK no trae un módulo de DRM comercial utilizable ni puede cargar el Widevine de Chrome, así que se espera que DAZN no reproduzca. Este cambio existe para comprobarlo con una prueba mínima y construir el resto solo si funciona.

## What Changes

- Empezar con una prueba mínima de reproducción de DAZN en WebKitGTK, que decide si la variante se construye o se descarta.
- Si reproduce, añadir la versión de Linux con GTK en `linux-gtk/`, escrita en Vala (con C donde Vala no llegue), con GTK4 y WebKitGTK 6.0, compilada con Meson.
- Si reproduce, cumplir el contrato de paridad de las capacidades neutrales y documentar las limitaciones por servidor gráfico.
- Si no reproduce, documentar el resultado en la hoja de ruta y cerrar el cambio sin construir la interfaz.

Fuera del alcance: empaquetado, la variante Qt y cualquier cambio en las demás plataformas. Rust queda descartado por ahora como alternativa de lenguaje.

## Capabilities

### New Capabilities

- `platform-linux-gtk`: requisitos propios de la versión de Linux con GTK (la prueba de reproducción como puerta, paridad con el contrato si pasa, limitaciones por servidor gráfico y requisitos documentados).

### Modified Capabilities

## Impact

- Si la prueba pasa: nueva carpeta `linux-gtk/` con el proyecto de Vala.
- En cualquier caso: `ROADMAP.md` registra el resultado de la prueba, y `README.md` el estado de esta variante.
- La prueba de reproducción (grupo 1 de las tareas) no depende de nada y puede hacerse desde ya. El resto depende de `extract-fullscreen-script`.
- Requiere una máquina con Linux para compilar y probar; no se puede verificar desde macOS.
