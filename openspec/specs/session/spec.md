# session Specification

## Purpose

Define cómo DAZNer conserva la sesión del usuario en DAZN y qué datos nunca guarda.

## Requirements

### Requirement: Sesión persistente

La aplicación SHALL conservar la sesión de DAZN entre aperturas, y la sesión SHALL compartirse entre los paneles y entre varias instancias abiertas a la vez.

#### Scenario: Reabrir la aplicación

- **WHEN** el usuario inicia sesión, cierra la aplicación y la vuelve a abrir
- **THEN** la sesión de DAZN sigue iniciada, mientras DAZN no la haya caducado

#### Scenario: Varias instancias

- **WHEN** el usuario abre una segunda instancia de la aplicación
- **THEN** esa instancia usa la misma sesión sin pedir iniciar sesión otra vez

### Requirement: Sin contraseñas

La aplicación SHALL NOT leer, almacenar ni registrar la contraseña del usuario ni lo que escribe en los campos de DAZN.

#### Scenario: Inicio de sesión

- **WHEN** el usuario escribe su contraseña en DAZN
- **THEN** la aplicación no la guarda ni la escribe en ningún registro

### Requirement: Varias instancias independientes

La aplicación SHALL permitir abrir varias instancias a la vez, cada una con su propia ventana y sus propios paneles.

#### Scenario: Tres instancias

- **WHEN** el usuario abre tres instancias
- **THEN** cada una tiene su ventana y reproduce un partido distinto sin afectar a las demás
