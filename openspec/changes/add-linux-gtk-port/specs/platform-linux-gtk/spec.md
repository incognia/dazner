## Purpose

Define los requisitos propios de la versión de DAZNer para Linux con GTK, incluida la prueba de reproducción que decide si esa variante se construye.

## ADDED Requirements

### Requirement: Reproducción comprobada como puerta

Antes de construir cualquier interfaz, el desarrollo SHALL comprobar con una prueba mínima si DAZN reproduce un partido con audio y video dentro de WebKitGTK, y SHALL registrar el resultado y la calidad obtenida.

#### Scenario: La reproducción funciona

- **WHEN** la prueba mínima abre DAZN, inicia sesión y reproduce un partido
- **THEN** se registran el resultado y la calidad, y se construye el resto de la versión

#### Scenario: La reproducción falla

- **WHEN** la prueba mínima no logra reproducir el partido
- **THEN** no se construye la interfaz, el resultado se documenta en la hoja de ruta y la variante queda como idea futura

### Requirement: Paridad con el contrato si la prueba pasa

Si la prueba de reproducción pasa, la versión de Linux con GTK SHALL cumplir los requisitos de las capacidades `window-chrome`, `panes`, `fullscreen-emulation`, `session`, `playback`, `diagnostics` y `shortcuts`, usando Ctrl como tecla de comando, salvo las limitaciones documentadas por servidor gráfico.

#### Scenario: Lista de verificación completa

- **WHEN** se ejecuta en Linux cada escenario de esas capacidades
- **THEN** todos se cumplen, o cada excepción queda documentada con su motivo y el servidor gráfico afectado

### Requirement: Limitaciones por servidor gráfico

Con Wayland, la versión SHALL emular la proporción fija corrigiendo el tamaño al redimensionar y SHALL limitar rellenar y centrar a ajustar el tamaño, porque el sistema no deja a la aplicación fijar su posición; con X11 SHALL cumplir ambos requisitos sin esa limitación.

#### Scenario: Rellenar y centrar en Wayland

- **WHEN** el usuario ejecuta rellenar y centrar en Wayland
- **THEN** la ventana adopta el tamaño máximo con su proporción y la posición la decide el compositor

### Requirement: Requisitos y compilación documentados

Si la versión se construye, el README SHALL indicar las distribuciones probadas, las versiones de GTK y WebKitGTK, y un comando de compilación que funcione en un clon nuevo.

#### Scenario: Clon nuevo

- **WHEN** una persona clona el repositorio en una distribución probada y sigue el README
- **THEN** obtiene un ejecutable sin pasos no documentados
