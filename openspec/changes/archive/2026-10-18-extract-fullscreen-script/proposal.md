# Proposal

## Why

El script que emula la pantalla completa vive hoy como cadena de texto dentro de `macos/DAZNer.swift`. Es la parte más delicada del proyecto, porque cada comportamiento de DAZN que descubrimos está ahí, y es JavaScript puro. Mientras siga incrustado en Swift, Windows y Linux tendrían que copiarlo y mantener cuatro versiones que se desviarían entre sí.

## What Changes

- Mover el script a `shared/fill-fullscreen.js`, común a todas las plataformas.
- Sustituir la dependencia de WebKit para registrar (`webkit.messageHandlers`) por un gancho neutro, `window.__daznerLog`, que cada plataforma enlaza a su propio mecanismo.
- Sustituir la sustitución de texto del diagnóstico por una variable global, `window.__daznerDebug`, que la plataforma define antes del script.
- Hacer que macOS cargue el script desde los recursos del paquete (`Contents/Resources`) y que `macos/build.sh` lo copie ahí.
- Sin cambios de comportamiento visibles en macOS.

Fuera del alcance: cambiar la lógica de la pantalla completa, y cualquier trabajo en Windows o Linux (lo hacen sus propios cambios, que dependen de este).

## Capabilities

### New Capabilities

### Modified Capabilities

- `fullscreen-emulation`: se añaden requisitos sobre el script compartido, el gancho de registro neutro y el control del diagnóstico desde fuera. Los requisitos de comportamiento existentes no cambian.

## Impact

- `macos/DAZNer.swift`: deja de incrustar el script y lo lee del paquete.
- `macos/build.sh`: copia `shared/fill-fullscreen.js` a `Contents/Resources`.
- `.gitignore`: ignora esa copia generada.
- Nuevo `shared/fill-fullscreen.js`.
- Es prerrequisito de `add-windows-port`, `add-linux-qt-port` y `add-linux-gtk-port`.
