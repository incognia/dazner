# Proposal

## Why

DAZN ya funciona bien en Chrome en Linux, lo que indica que un motor basado en Chromium puede reproducirlo con el DRM Widevine. Qt WebEngine es Chromium incrustado en Qt, así que es la variante de Linux con más probabilidades de funcionar, y su interfaz en QML encaja con el estilo de KDE.

## What Changes

- Añadir la versión de Linux con Qt en `linux-qt/`, escrita en QML (Qt Quick, `WebEngineView`) con un `main.cpp` mínimo y compilada con CMake.
- Cumplir el contrato de paridad de las capacidades neutrales, con Ctrl como tecla de comando, y documentar las limitaciones según el servidor gráfico (X11 o Wayland).
- Usar el módulo Widevine de la instalación de Chrome del usuario, sin redistribuirlo.
- Cargar el script compartido `shared/fill-fullscreen.js` y enlazar su gancho de registro.
- Empezar con una prueba mínima de reproducción de DAZN, que decide si se sigue.

Fuera del alcance: empaquetado (AppImage, Flatpak), la variante GTK y cualquier cambio en las demás plataformas.

## Capabilities

### New Capabilities

- `platform-linux-qt`: requisitos propios de la versión de Linux con Qt (paridad con el contrato, prueba de reproducción previa, módulo de DRM tomado del sistema sin redistribuirlo, limitaciones por servidor gráfico y requisitos documentados).

### Modified Capabilities

## Impact

- Nueva carpeta `linux-qt/` con el proyecto de QML y C++.
- `README.md` y `ROADMAP.md`: estado de Linux Qt, requisitos y compilación.
- Depende de `extract-fullscreen-script`.
- Requiere una máquina con Linux para compilar y probar; no se puede verificar desde macOS.
