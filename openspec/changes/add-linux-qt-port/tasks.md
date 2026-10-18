# Tasks

## 1. Prueba de reproducción (puerta: detenerse si falla)

- [ ] 1.1 Crear en `linux-qt/` un proyecto mínimo de QML con un `WebEngineView` que abra `https://www.dazn.com/` y un `main.cpp` que pase al motor la ruta del módulo Widevine de Chrome; verificar compilando con CMake en Linux sin errores (solo se puede verificar en Linux).
- [ ] 1.2 Comprobar que esa instalación de Qt WebEngine incluye los códecs propietarios, iniciar sesión y reproducir un partido; anotar en `design.md` el origen de Qt usado, los códecs, la calidad máxima y cualquier error. **Si no reproduce, detenerse aquí**, documentar la causa en `ROADMAP.md` y no seguir con los grupos siguientes (solo se puede verificar en Linux).

## 2. Ventana

- [ ] 2.1 Ventana sin bordes con franja de arrastre de 14 px y arrastre con tecla modificadora usando `startSystemMove`; verificar los escenarios de «Mover la ventana» en X11 y en Wayland (solo se puede verificar en Linux).
- [ ] 2.2 Proporción fija 16:9 y 32:9, con corrección del tamaño en Wayland; verificar los escenarios de «Proporción fija» en ambos servidores gráficos (solo se puede verificar en Linux).
- [ ] 2.3 Rellenar y centrar, y siempre encima, con las limitaciones de Wayland; verificar los escenarios de `platform-linux-qt` y de `window-chrome` (solo se puede verificar en Linux).

## 3. Paneles

- [ ] 3.1 Modo de uno y dos paneles con hueco de 8 px dentro del ancho de la ventana; verificar las medidas del escenario de «Hueco entre paneles» (solo se puede verificar en Linux).
- [ ] 3.2 Crear el segundo panel a demanda y destruirlo al volver a uno, sin refrescar el primero; verificar que el primer panel sigue reproduciendo y que el proceso del segundo desaparece (solo se puede verificar en Linux).
- [ ] 3.3 Audio por foco con `audioMuted`, cambio de panel y abrir dirección; verificar los escenarios de «Audio por foco» y de abrir dirección (solo se puede verificar en Linux).
- [ ] 3.4 Abrir en el mismo panel los enlaces de ventana nueva; verificar el escenario de `playback` (solo se puede verificar en Linux).

## 4. Pantalla completa y sesión

- [ ] 4.1 Cargar `shared/fill-fullscreen.js` con `userScripts` y las variables previas, y enlazar `window.__daznerLog` al canal de mensajes; verificar con `--debug` que `debug.log` recibe eventos (solo se puede verificar en Linux).
- [ ] 4.2 Probar la pantalla completa del video principal y de uno secundario, la general con cuatro videos y Esc; verificar los escenarios de `fullscreen-emulation` (solo se puede verificar en Linux).
- [ ] 4.3 Sesión persistente con un perfil de almacenamiento propio, compartida entre paneles e instancias; verificar los escenarios de `session` abriendo tres instancias (solo se puede verificar en Linux).

## 5. Atajos, aviso de Widevine y documentación

- [ ] 5.1 Atajos con Ctrl y acciones de edición; verificar los escenarios de `shortcuts` (solo se puede verificar en Linux).
- [ ] 5.2 Avisar cuando no se encuentre el módulo Widevine, con instrucciones; verificar renombrando temporalmente la ubicación y comprobando el aviso (solo se puede verificar en Linux).
- [ ] 5.3 Documentar distribuciones probadas, Qt con códecs, ubicación de Widevine y compilación en `README.md`, y actualizar el estado en `ROADMAP.md`; verificar con `openspec validate add-linux-qt-port --strict`.
- [ ] 5.4 Ejecutar la lista de verificación de paridad completa y anotar las excepciones con su motivo; verificar que `platform-linux-qt` queda cumplida o con excepciones documentadas (solo se puede verificar en Linux).

## Workflow follow-up

- Archivar con `/opsx:archive` y registrar los cambios con `/changelogger` y `/commit`.
