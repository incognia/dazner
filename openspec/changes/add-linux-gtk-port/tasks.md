# Tasks

## 1. Prueba de reproducción (puerta: detenerse si falla)

- [ ] 1.1 Crear en `linux-gtk/` una aplicación mínima en Vala con una vista de WebKitGTK 6.0 que abra `https://www.dazn.com/`; verificar compilando con Meson en Linux sin errores (solo se puede verificar en Linux).
- [ ] 1.2 Iniciar sesión y reproducir un partido; anotar en `design.md` si hay audio y video, la calidad máxima y cualquier error; verificar que el resultado queda escrito. **Si no reproduce, detenerse aquí**, documentar el resultado en `ROADMAP.md`, dejar la variante como idea futura y no seguir con los grupos siguientes (solo se puede verificar en Linux).

## 2. Ventana (solo si la tarea 1.2 pasa)

- [ ] 2.1 Ventana sin bordes con franja de arrastre de 14 px y arrastre con tecla modificadora; verificar los escenarios de «Mover la ventana» en X11 y en Wayland (solo se puede verificar en Linux).
- [ ] 2.2 Proporción fija 16:9 y 32:9, con corrección del tamaño en Wayland; verificar los escenarios de «Proporción fija» en ambos servidores gráficos (solo se puede verificar en Linux).
- [ ] 2.3 Rellenar y centrar, y siempre encima, con las limitaciones de Wayland; verificar los escenarios de `platform-linux-gtk` y de `window-chrome` (solo se puede verificar en Linux).

## 3. Paneles (solo si la tarea 1.2 pasa)

- [ ] 3.1 Modo de uno y dos paneles con hueco de 8 px dentro del ancho de la ventana; verificar las medidas del escenario de «Hueco entre paneles» (solo se puede verificar en Linux).
- [ ] 3.2 Crear el segundo panel a demanda y destruirlo al volver a uno, sin refrescar el primero; verificar que el primer panel sigue reproduciendo y que el proceso del segundo desaparece (solo se puede verificar en Linux).
- [ ] 3.3 Audio por foco, cambio de panel y abrir dirección; verificar los escenarios de «Audio por foco» y de abrir dirección (solo se puede verificar en Linux).
- [ ] 3.4 Abrir en el mismo panel los enlaces de ventana nueva; verificar el escenario de `playback` (solo se puede verificar en Linux).

## 4. Pantalla completa y sesión (solo si la tarea 1.2 pasa)

- [ ] 4.1 Cargar `shared/fill-fullscreen.js` con las variables previas y enlazar `window.__daznerLog` al gestor de mensajes; verificar con `--debug` que `debug.log` recibe eventos (solo se puede verificar en Linux).
- [ ] 4.2 Probar la pantalla completa del video principal y de uno secundario, la general con cuatro videos y Esc; verificar los escenarios de `fullscreen-emulation` (solo se puede verificar en Linux).
- [ ] 4.3 Sesión persistente con almacenamiento propio, compartida entre paneles e instancias; verificar los escenarios de `session` abriendo tres instancias (solo se puede verificar en Linux).

## 5. Atajos y documentación (solo si la tarea 1.2 pasa)

- [ ] 5.1 Atajos con Ctrl y acciones de edición; verificar los escenarios de `shortcuts` (solo se puede verificar en Linux).
- [ ] 5.2 Documentar distribuciones probadas, versiones de GTK y WebKitGTK, y compilación en `README.md`, y actualizar el estado en `ROADMAP.md`; verificar con `openspec validate add-linux-gtk-port --strict`.
- [ ] 5.3 Ejecutar la lista de verificación de paridad completa y anotar las excepciones con su motivo; verificar que `platform-linux-gtk` queda cumplida o con excepciones documentadas (solo se puede verificar en Linux).

## Workflow follow-up

- Archivar con `/opsx:archive` y registrar los cambios con `/changelogger` y `/commit`.
