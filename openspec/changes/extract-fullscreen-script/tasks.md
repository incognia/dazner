# Tasks

## 1. Extraer el script

- [ ] 1.1 Crear `shared/fill-fullscreen.js` con el script actual de `macos/DAZNer.swift`; verificar con `node --check shared/fill-fullscreen.js` sin errores de sintaxis.
- [ ] 1.2 Reemplazar la marca de diagnóstico por `window.__daznerDebug === true` y las llamadas a `webkit.messageHandlers.dbg` por `window.__daznerLog` (solo si existe); verificar con `grep -n "webkit\." shared/fill-fullscreen.js` sin resultados y con `node --check`.

## 2. Cargarlo en macOS

- [ ] 2.1 Hacer que `macos/build.sh` copie el script a `macos/DAZNer.app/Contents/Resources/`; verificar que tras `./macos/build.sh` el archivo existe en el paquete.
- [ ] 2.2 Cambiar `macos/DAZNer.swift` para leer el script del paquete, definir `window.__daznerDebug` y, solo con `--debug`, `window.__daznerLog`, y eliminar la cadena incrustada; verificar que compila sin errores con `./macos/build.sh`.
- [ ] 2.3 Ignorar la copia generada en `.gitignore`; verificar que `git status` no la muestra tras compilar.

## 3. Verificar que macOS se comporta igual (manual, en macOS)

- [ ] 3.1 Con un partido reproduciéndose, probar la pantalla completa del video principal y de uno secundario, la general con cuatro videos y Esc para salir; verificar que cada caso cumple los escenarios de `fullscreen-emulation`.
- [ ] 3.2 Repetir la prueba con dos paneles y comprobar que la pantalla completa llena solo el panel en que se pidió.
- [ ] 3.3 Abrir con `--debug` y comprobar que `debug.log` registra los eventos; abrir sin argumentos y comprobar que no se escribe ningún registro.

## 4. Documentación y validación

- [ ] 4.1 Marcar la fase 1 como hecha en `ROADMAP.md` y actualizar la descripción de la estructura en `README.md`; verificar con `openspec validate extract-fullscreen-script --strict`.

## Workflow follow-up

- Archivar con `/opsx:archive` y registrar los cambios con `/changelogger` y `/commit`.
