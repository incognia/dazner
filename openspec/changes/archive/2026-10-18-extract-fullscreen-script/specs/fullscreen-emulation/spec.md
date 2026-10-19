## ADDED Requirements

### Requirement: Script compartido

La emulación de pantalla completa SHALL implementarse con un único script JavaScript, común a todas las plataformas, que cada versión carga en cada panel antes de que se ejecute la página.

#### Scenario: Mismo archivo en todas las versiones

- **WHEN** se compila cualquier versión de la aplicación
- **THEN** la emulación de pantalla completa usa el contenido de `shared/fill-fullscreen.js` sin copias modificadas por plataforma

### Requirement: Registro mediante un gancho neutro

El script SHALL reportar su diagnóstico solo mediante la función global `window.__daznerLog`, que cada plataforma enlaza a su propio mecanismo, y SHALL NOT fallar ni registrar nada si esa función no existe.

#### Scenario: Con gancho y diagnóstico activo

- **WHEN** la plataforma define `window.__daznerLog` y activa el diagnóstico
- **THEN** el script envía sus eventos a esa función

#### Scenario: Sin gancho

- **WHEN** la plataforma no define `window.__daznerLog`
- **THEN** el script funciona igual y no produce errores

### Requirement: Diagnóstico controlado desde fuera

El script SHALL leer si el diagnóstico está activo de la variable global `window.__daznerDebug`, definida por la plataforma antes de cargarlo, y SHALL NOT medir ni registrar nada cuando vale falso o no existe.

#### Scenario: Diagnóstico apagado

- **WHEN** `window.__daznerDebug` no está definida o vale falso
- **THEN** el script no mide ni registra eventos y el comportamiento de pantalla completa no cambia
