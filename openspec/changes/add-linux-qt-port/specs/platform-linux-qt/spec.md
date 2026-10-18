## Purpose

Define los requisitos propios de la versión de DAZNer para Linux con Qt, que debe ofrecer el comportamiento de la de macOS dentro de las particularidades de cada servidor gráfico.

## ADDED Requirements

### Requirement: Paridad con el contrato

La versión de Linux con Qt SHALL cumplir los requisitos de las capacidades `window-chrome`, `panes`, `fullscreen-emulation`, `session`, `playback`, `diagnostics` y `shortcuts`, usando Ctrl como tecla de comando, salvo las limitaciones documentadas por servidor gráfico.

#### Scenario: Lista de verificación completa

- **WHEN** se ejecuta en Linux cada escenario de esas capacidades
- **THEN** todos se cumplen, o cada excepción queda documentada con su motivo y el servidor gráfico afectado

### Requirement: Reproducción comprobada primero

Antes de construir el resto de la versión, el desarrollo SHALL comprobar con una prueba mínima que DAZN reproduce un partido con audio y video dentro de Qt WebEngine, SHALL comprobar que esa instalación de Qt incluye los códecs de video y audio que DAZN necesita, y SHALL registrar la calidad máxima obtenida.

#### Scenario: La reproducción funciona

- **WHEN** la prueba mínima abre DAZN, inicia sesión y reproduce un partido
- **THEN** se registran el resultado, los códecs disponibles y la calidad, y el trabajo continúa

#### Scenario: Faltan códecs o la reproducción falla

- **WHEN** la prueba no reproduce porque faltan códecs o por cualquier otro motivo
- **THEN** el trabajo se detiene y se documenta la causa y cómo obtener un Qt WebEngine adecuado

### Requirement: Módulo de DRM tomado del sistema

La versión de Linux con Qt SHALL usar el módulo Widevine de una instalación de Chrome del usuario, indicando su ubicación al arrancar, y SHALL NOT incluir ni redistribuir ese módulo.

#### Scenario: Chrome instalado

- **WHEN** el usuario tiene Chrome instalado y abre la aplicación
- **THEN** la aplicación localiza el módulo Widevine de Chrome y lo usa para reproducir

#### Scenario: Chrome no instalado

- **WHEN** no se encuentra el módulo Widevine
- **THEN** la aplicación muestra un aviso que explica cómo obtenerlo y no intenta reproducir

### Requirement: Limitaciones por servidor gráfico

Con Wayland, la versión SHALL emular la proporción fija corrigiendo el tamaño al redimensionar y SHALL limitar rellenar y centrar a ajustar el tamaño, porque el sistema no deja a la aplicación fijar su posición; con X11 SHALL cumplir ambos requisitos sin esa limitación.

#### Scenario: Rellenar y centrar en Wayland

- **WHEN** el usuario ejecuta rellenar y centrar en Wayland
- **THEN** la ventana adopta el tamaño máximo con su proporción y la posición la decide el compositor

#### Scenario: Rellenar y centrar en X11

- **WHEN** el usuario ejecuta rellenar y centrar en X11
- **THEN** la ventana queda con el tamaño máximo, su proporción y centrada

### Requirement: Requisitos y compilación documentados

El README SHALL indicar las distribuciones probadas, la versión de Qt, el origen de Qt WebEngine con códecs, la ubicación del módulo Widevine y un comando de compilación que funcione en un clon nuevo.

#### Scenario: Clon nuevo

- **WHEN** una persona clona el repositorio en una distribución probada y sigue el README
- **THEN** obtiene un ejecutable sin pasos no documentados
