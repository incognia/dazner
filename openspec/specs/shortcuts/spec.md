# shortcuts Specification

## Purpose

Define los atajos de teclado de DAZNer y las acciones de edición de texto, con la tecla de comando propia de cada plataforma.

## Requirements

### Requirement: Atajos de la aplicación

La aplicación SHALL ofrecer atajos con la tecla de comando de la plataforma (⌘ en macOS, Ctrl en Windows y Linux): 1 y 2 para el número de paneles, L para abrir una dirección, R para recargar, H para el inicio de DAZN, ` para cambiar de panel, T para siempre encima, F para rellenar y centrar, W para cerrar y Q para salir.

#### Scenario: Recargar

- **WHEN** el usuario pulsa el atajo de recargar
- **THEN** el panel con foco se recarga y los demás no

#### Scenario: Salir

- **WHEN** el usuario pulsa el atajo de salir
- **THEN** la aplicación se cierra por completo

### Requirement: Edición de texto

La aplicación SHALL permitir deshacer, cortar, copiar, pegar y seleccionar todo en los campos de texto de DAZN, con los atajos y el menú de edición habituales de la plataforma.

#### Scenario: Pegar una contraseña

- **WHEN** el usuario pega texto en un campo de DAZN
- **THEN** el texto aparece en el campo
