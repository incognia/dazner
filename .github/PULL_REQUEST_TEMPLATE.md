<!--
Título del PR: formato Conventional Commits en inglés (UK), por ejemplo
"feat(windows): add borderless window". Cada sección de abajo es obligatoria.
Se rechaza un PR que no pase `~/rules/scripts/check-pr.sh` (o `/pr-check`).
-->

## Contexto

<!-- Qué problema resuelve y a qué cambio de OpenSpec corresponde (enlaza openspec/changes/<cambio>/). -->

## Qué cambia

<!-- Lista corta de cambios concretos. -->

## Cómo se verificó

<!--
Una fila por tarea de OpenSpec. Usa ✅ para lo que ejecutaste (indica en qué sistema operativo)
y ⏳ para lo pendiente (indica dónde debe probarse). No marques como hecho lo que no ejecutaste.
-->

| Tarea | Estado | Sistema y evidencia |
|---|---|---|
| | | |

## Qué no se probó

<!-- Lo que no pudiste ejecutar y dónde debería probarse. Escribe «Nada» solo si es cierto. -->

## Decisiones

<!-- Decisiones de diseño que tomaste y dónde quedaron registradas (por ejemplo, en design.md). -->

## Riesgos

<!-- Qué puede salir mal y cómo se mitiga. -->

## Herramienta de IA

<!-- Herramienta y modelo que usaste, o «Ninguna». -->

## Lista de verificación

- [ ] `/pr-check` (o `~/rules/scripts/check-pr.sh --base origin/main`) pasa sin fallos
- [ ] `openspec validate --all --strict` pasa
- [ ] *Commits* atómicos, en inglés (UK), con Conventional Commits y `Co-Authored-By` de la herramienta usada
- [ ] `CHANGELOG.md` cambia solo en el último *commit*, añadiendo viñetas con la fecha en hora del centro de México (UTC-6)
- [ ] El PR solo toca archivos de su cambio: sin binarios, registros ni reformateos
- [ ] Sin credenciales ni datos personales
