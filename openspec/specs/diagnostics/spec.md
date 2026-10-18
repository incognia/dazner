# diagnostics Specification

## Purpose

Define el modo de diagnóstico opcional de DAZNer, que ayuda a investigar fallos de la página sin afectar el uso normal.

## Requirements

### Requirement: Modo de diagnóstico opcional

La aplicación SHALL activar el modo de diagnóstico solo cuando se inicia con el argumento `--debug`, y SHALL dejarlo desactivado de forma predeterminada.

#### Scenario: Inicio normal

- **WHEN** el usuario abre la aplicación sin argumentos
- **THEN** no se escribe ningún registro y el inspector web queda deshabilitado

#### Scenario: Inicio con diagnóstico

- **WHEN** el usuario abre la aplicación con `--debug`
- **THEN** se escribe `debug.log` junto a la aplicación y el inspector web queda habilitado

### Requirement: Eventos registrados

En modo de diagnóstico, la aplicación SHALL registrar los eventos de pantalla completa (elemento, tamaño y estado), los eventos de cada panel (cambio de tamaño, carga y descarga de la página) y la medición del hueco del *multiview*.

#### Scenario: Pantalla completa en diagnóstico

- **WHEN** DAZN pide la pantalla completa con el modo de diagnóstico activo
- **THEN** el registro anota el elemento, su tamaño antes y después, y la salida del modo
