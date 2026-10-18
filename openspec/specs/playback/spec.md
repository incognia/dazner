# playback Specification

## Purpose

Define qué carga DAZNer y bajo qué condiciones reproduce contenido, incluidas las prohibiciones sobre el DRM y los controles de acceso.

## Requirements

### Requirement: Sitio oficial de DAZN

La aplicación SHALL abrir el sitio web oficial de DAZN al iniciar y en cada panel nuevo.

#### Scenario: Inicio

- **WHEN** el usuario abre la aplicación
- **THEN** el panel muestra el inicio del sitio de DAZN

### Requirement: Reproducción con el DRM del sistema

La aplicación SHALL reproducir el contenido de DAZN con una suscripción válida usando el DRM del motor web nativo de la plataforma.

#### Scenario: Partido en directo

- **WHEN** el usuario con suscripción válida abre un partido en directo
- **THEN** el video se reproduce con audio

### Requirement: Sin eludir protecciones

La aplicación SHALL NOT eludir el DRM, los controles de acceso ni los límites de reproducción de DAZN, y SHALL NOT redistribuir módulos de DRM.

#### Scenario: Límite de DAZN

- **WHEN** DAZN rechaza o limita una reproducción
- **THEN** la aplicación muestra lo que DAZN responda y no intenta evitarlo

### Requirement: Enlaces que piden una ventana nueva

La aplicación SHALL abrir en el mismo panel los enlaces que piden una ventana nueva.

#### Scenario: Enlace de ventana nueva

- **WHEN** DAZN abre un enlace con destino de ventana nueva
- **THEN** la dirección se carga en el panel desde el que se abrió y no aparece otra ventana
