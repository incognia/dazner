# fullscreen-emulation Specification

## Purpose

Define cómo la pantalla completa que pide DAZN se resuelve dentro de la ventana o del panel, en lugar de pasar a la pantalla completa del sistema, incluso con el *multiview* de DAZN.

## Requirements

### Requirement: Llenar la ventana o el panel

Cuando DAZN pida la pantalla completa de un elemento, la aplicación SHALL estirarlo hasta llenar la ventana con un panel, o su panel con dos paneles, sin entrar a la pantalla completa del sistema.

#### Scenario: Un panel

- **WHEN** DAZN pide la pantalla completa con un panel abierto
- **THEN** el elemento llena toda la ventana y el sistema no cambia a pantalla completa

#### Scenario: Dos paneles

- **WHEN** DAZN pide la pantalla completa en uno de dos paneles
- **THEN** el elemento llena solo ese panel y el otro panel no cambia

### Requirement: Salir de la pantalla completa

La aplicación SHALL salir del modo con la tecla Esc o con el mismo botón de DAZN, y SHALL restaurar el estado y el estilo originales del elemento.

#### Scenario: Salir con Esc

- **WHEN** el usuario pulsa Esc durante la pantalla completa
- **THEN** el elemento regresa a su lugar con su tamaño y estilo anteriores

### Requirement: Compatibilidad con el multiview de DAZN

La aplicación SHALL resolver la pantalla completa del botón general del *multiview*, con dos o cuatro videos, y la del botón de cada video individual, principal o secundario.

#### Scenario: Botón general con cuatro videos

- **WHEN** el usuario usa la pantalla completa general con cuatro videos
- **THEN** la cuadrícula llena el área sin desplazarse ni dejar una columna vacía

#### Scenario: Botón de un video individual

- **WHEN** el usuario usa la pantalla completa de un video principal o secundario
- **THEN** ese video llena el área y es visible, sin quedar vacío ni negro

### Requirement: Resistencia a los redibujados de DAZN

La aplicación SHALL mantener la pantalla completa aunque DAZN reescriba las clases de sus contenedores, SHALL mostrar los contenedores que DAZN oculte y SHALL ocultar el resto de la página mientras dure.

#### Scenario: DAZN reescribe sus contenedores

- **WHEN** DAZN reescribe las clases del contenedor del reproductor tras detectar la pantalla completa
- **THEN** el elemento sigue llenando el área y sigue visible

### Requirement: Estado visible para la página

La aplicación SHALL hacer que la página vea el elemento como elemento en pantalla completa y que reciba los eventos de cambio de pantalla completa al entrar y al salir.

#### Scenario: La página consulta el estado

- **WHEN** DAZN consulta qué elemento está en pantalla completa durante el modo
- **THEN** obtiene el elemento estirado, y al salir obtiene que no hay ninguno
