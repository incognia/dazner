## Purpose

Define los requisitos propios de la versión de DAZNer para Windows, que debe ofrecer el mismo comportamiento que la de macOS dentro de las particularidades del sistema.

## ADDED Requirements

### Requirement: Paridad con el contrato

La versión de Windows SHALL cumplir los requisitos de las capacidades `window-chrome`, `panes`, `fullscreen-emulation`, `session`, `playback`, `diagnostics` y `shortcuts`, usando Ctrl como tecla de comando.

#### Scenario: Lista de verificación completa

- **WHEN** se ejecuta en Windows cada escenario de esas capacidades
- **THEN** todos se cumplen, o cada excepción queda documentada con su motivo

### Requirement: Reproducción comprobada primero

Antes de construir el resto de la versión, el desarrollo SHALL comprobar con una prueba mínima que DAZN reproduce un partido con audio y video dentro del motor web elegido, y SHALL registrar la calidad máxima obtenida.

#### Scenario: La reproducción funciona

- **WHEN** la prueba mínima abre DAZN, inicia sesión y reproduce un partido
- **THEN** se registran el resultado y la calidad, y el trabajo continúa

#### Scenario: La reproducción falla

- **WHEN** la prueba mínima no logra reproducir el partido
- **THEN** el trabajo se detiene y el resultado se documenta sin construir el resto

### Requirement: Proporción y centrado en el monitor

La versión de Windows SHALL conservar la proporción de la ventana al arrastrar sus bordes en cualquier monitor, y la acción de rellenar y centrar SHALL usar el área de trabajo del monitor en que está la ventana.

#### Scenario: Dos monitores

- **WHEN** la ventana está en el segundo monitor y el usuario ejecuta rellenar y centrar
- **THEN** la ventana ocupa el máximo posible del área de trabajo de ese monitor, con su proporción, y queda centrada en él

### Requirement: Carpeta de sesión propia

La versión de Windows SHALL guardar los datos de la sesión en una carpeta de datos del usuario exclusiva de DAZNer, sin usar ni modificar el perfil de otros navegadores.

#### Scenario: Primera apertura

- **WHEN** el usuario abre la aplicación por primera vez
- **THEN** se crea la carpeta de datos de DAZNer y no se toca ningún perfil de otro navegador

### Requirement: Requisitos y compilación documentados

El README SHALL indicar la versión de Windows, el entorno de ejecución y las herramientas necesarias, y SHALL ofrecer dos vías de compilación que funcionen en un clon nuevo: desde Visual Studio y desde PowerShell.

#### Scenario: Compilar con PowerShell

- **WHEN** una persona clona el repositorio en Windows y ejecuta el script de compilación de PowerShell que indica el README
- **THEN** obtiene un ejecutable sin pasos no documentados

#### Scenario: Compilar con Windows PowerShell 5.1

- **WHEN** una persona ejecuta el script de compilación en Windows PowerShell 5.1
- **THEN** el script funciona igual que en PowerShell 7 y no muestra caracteres corruptos

#### Scenario: Compilar con Visual Studio

- **WHEN** una persona abre la solución en Visual Studio y compila
- **THEN** obtiene el mismo ejecutable que con PowerShell
