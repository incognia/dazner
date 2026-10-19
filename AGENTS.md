# Guía para agentes

*Última modificación: 18 de octubre de 2026, 20:05 (CST)*

Este archivo es para un agente de IA que trabaja en este repositorio, sobre todo si lo clonó en Windows o Linux para construir una de las versiones pendientes. El autor mantiene un repositorio de reglas personales (`rules`) con las *skills* de trabajo (`/commit`, `/changelogger`, `/git-init`, `/licensing`) y sus procedimientos. Está presente en sus máquinas con Linux, en WSL y en Windows, así que **si existe, manda sobre el resumen de este archivo**; este archivo recoge lo esencial por si no está.

## Qué es DAZNer

Visor mínimo de DAZN (NFL Game Pass): abre el sitio oficial en una ventana sin bordes, con uno o dos paneles y una pantalla completa que llena la ventana o el panel. Hoy existe solo la versión de macOS. Faltan Windows, Linux con Qt y Linux con GTK. Licencia GPLv3; aviso de marcas en `NOTICE.md`.

## Estructura

```text
macos/     Swift sobre WKWebView; DAZNer.swift, build.sh y el paquete DAZNer.app
shared/    ícono, imágenes y scripts comunes, entre ellos fill-fullscreen.js
openspec/  especificaciones y cambios (el plan de trabajo, ver abajo)
ROADMAP.md visión general y orden de ejecución
TODO.md    pendientes por orden y por máquina
.github/   plantilla de PR, configuración de pr-check y el flujo de GitHub Actions que corre el script de rules
windows/   (por crear) linux-qt/ (por crear)  linux-gtk/ (por crear)
```

Cada plataforma vive en su carpeta y usa su lenguaje nativo:

| Plataforma | Lenguaje y herramienta | Motor web |
|---|---|---|
| macOS (hecha) | Swift, `swiftc` | WebKit (`WKWebView`) |
| Windows | C# (.NET) con WPF, `dotnet build` | WebView2 (Chromium) |
| Linux Qt | C++/QML con CMake | Qt WebEngine (Chromium) |
| Linux GTK | Vala/C con Meson | WebKitGTK 6.0 |

## Cómo se trabaja: OpenSpec

El plan está en `openspec/`. Las especificaciones de `openspec/specs/` describen el comportamiento de la versión de macOS y son **el contrato de paridad** que debe cumplir cada versión nueva. Cada versión nueva es un cambio en `openspec/changes/`:

| Cambio | Qué hace | Se puede probar en |
|---|---|---|
| `add-windows-port` | Versión de Windows | Windows |
| `add-linux-qt-port` | Versión de Linux con Qt | Linux |
| `add-linux-gtk-port` | Versión de Linux con GTK (experimental) | Linux |

**Orden:** el script de pantalla completa ya es compartido: vive en `shared/fill-fullscreen.js` y macOS lo carga desde el paquete (cambio `extract-fullscreen-script`, ya archivado). La prueba de reproducción (grupo 1) de cada versión nueva no depende de nada y se hace primero; el resto de cada versión (grupos 2 a 5) sigue en cuanto esa prueba pase. Las versiones son independientes entre sí. El detalle está en la sección «Orden de ejecución» de `ROADMAP.md` y los pendientes, por máquina, en `TODO.md`.

Para trabajar un cambio:

1. Instalar OpenSpec (Node 20.19 o superior): `npm install -g @fission-ai/openspec@latest`, o usar `npx @fission-ai/openspec@latest <comando>`.
2. Con Claude Code, reiniciarlo para ver los comandos de `.claude/commands/opsx/` y usar `/opsx:apply <cambio>`. Sin esos comandos, leer `openspec/changes/<cambio>/` (propuesta, especificaciones, diseño y tareas) y seguir las tareas en orden.
3. Ver el estado con `openspec list`, `openspec status --change <cambio>` y validar con `openspec validate --all --strict`.
4. Marcar una tarea (`- [x]`) solo después de ejecutar su verificación.

## Reglas que no se negocian

- **La prueba de reproducción va primero.** El primer grupo de cada versión nueva comprueba que DAZN reproduce dentro del motor web de esa plataforma. **Si falla, detenerse**, documentar el resultado en `ROADMAP.md` y no construir el resto.
- **No eludir protecciones.** Prohibido eludir DRM, controles de acceso o límites de reproducción, y redistribuir módulos de DRM (por ejemplo, Widevine). Se usan los del sistema o los de una instalación de Chrome del usuario.
- **No afirmar lo que no se ejecutó.** No se marca una tarea como hecha ni se dice que algo funciona en una plataforma si no se pudo compilar y probar ahí. Si una tarea solo se verifica en otro sistema operativo, se deja pendiente y se dice dónde probarla.
- **Credenciales:** DAZNer nunca lee, guarda ni registra contraseñas. No escribas credenciales en archivos, registros ni *commits*.
- **Marcas:** no uses logotipos de DAZN ni de la NFL. El ícono del proyecto es propio (`shared/assets/icon.png`).
- **No tocar `macos/` salvo que el cambio lo pida.** Cualquier modificación a `shared/fill-fullscreen.js` exige repetir la verificación manual de pantalla completa en macOS.

## Lo que ya se descubrió de DAZN

Esto explica por qué el script de pantalla completa es como es. No lo reinventes:

- **DRM:** DAZN funciona en Chrome en Windows y Linux (Widevine) y en Safari/WebKit en macOS (FairPlay). En Firefox da problemas. WebKit para Windows no sirve (sin DRM). Se espera que WebKitGTK tampoco reproduzca.
- **Pantalla completa:** la página usa la API estándar. El script la intercepta y estira el elemento para llenar la ventana o el panel en lugar de pasar a la pantalla completa del sistema.
- **El *multiview* de DAZN rompe una emulación ingenua:** al detectar la pantalla completa deja el contenedor padre con `opacity: 0` y reescribe las clases de sus contenedores. Por eso el script fuerza la opacidad de los ancestros, oculta el resto de la página y repone sus marcas con un `MutationObserver`.
- **Margen del contenedor:** el contenedor del *multiview* trae un margen izquierdo que DAZN calcula para centrarlo (267 px en una ventana de 2478 px). Hay que fijar márgenes y posiciones en línea con `!important`.
- **Hueco entre videos:** 4 px de la cuadrícula más 2 px de borde por celda a cada lado, es decir, 8 px entre videos. Se midió de 1280×720 a 2478×1394. Con dos paneles se deja 8 px dentro del ancho de la ventana para conservar la proporción 32:9.
- **Cambiar el tamaño de la ventana refresca el panel:** DAZN rehace el reproductor. Por eso, al abrir el segundo panel, la ventana cambia primero y el primer panel conserva su tamaño.
- **La barra gris del borde derecho en pantalla completa** es el panel de estadísticas de DAZN. No es un error.
- Una captura de pantalla de un video con DRM sale en negro; no sirve para diagnosticar. La evidencia que se acepta son fotos de celular en horizontal (ver `CHALLENGE.md`); no se usan videos ni capturadoras de video, porque estas últimas eluden el DRM.

## Depuración

- `--debug` escribe `debug.log` junto a la aplicación y habilita el inspector web. Está apagado por omisión y no debe versionarse.
- El script compartido solo mide y registra si la plataforma define `window.__daznerDebug`. Registra mediante `window.__daznerLog`.

## Repositorio de reglas del autor (`rules`)

Ubicación según el sistema:

| Sistema | Ubicación de `rules` |
|---|---|
| macOS, Linux y WSL | `~/rules` |
| Windows (nativo) | la base del perfil de usuario (`%USERPROFILE%\rules`) o `C:\rules` |

Qué usar de ahí, si existe:

- **Flujo de trabajo:** `/changelogger` y `/commit` (procedimientos en `cot/changelog.md` y `cot/committing.md`), y `/git-init` y `/licensing` para configurar un repositorio nuevo.
- **Estilo del español:** `rulesets/LINGUISTICS.md`.
- **Rutas:** las *skills* escriben `~/rules/...`. En Windows nativo hay que resolver esa ruta con la ubicación de la tabla. Algunas piezas (`scripts/commit_trailer.py`, scripts de `bash`) necesitan Python o un *shell* de tipo Unix; en Windows funcionan mejor desde WSL.
- **Si no existe `rules`:** seguir el resumen de la sección siguiente y avisar al usuario de que falta.

## Flujo de trabajo en Windows

El autor usa **dos entornos a la vez** en la misma máquina con Windows:

- **Git, siempre desde WSL.** Git de Windows mete ruido de caracteres, así que `git`, `/changelogger` y `/commit` se ejecutan en WSL, donde existe `~/rules`. No ejecutes `git` desde PowerShell ni desde Visual Studio.
- **Compilar y probar, desde Windows nativo**, con Visual Studio (abriendo la solución de `windows/`) o con PowerShell (`dotnet build`, o el `build.ps1` que se añada). WPF y WebView2 solo se ejecutan en Windows.
- **Codificación:** todo el repositorio es UTF-8. En Windows, muchos programas y consolas usan Windows-1252 (la «ANSI» de Windows, parecida a ISO-8859-1), y eso corrompe acentos, «», ñ y símbolos como ⌘. Reglas:
  - `.editorconfig` fija UTF-8 y LF para todo, y UTF-8 con BOM para `.cs`, `.xaml` y `.ps1`, porque Windows PowerShell 5.1 lee un script sin BOM como ANSI. Respétalo.
  - Los mensajes de `windows/build.ps1` van en ASCII, sin acentos, por robustez.
  - En Windows PowerShell 5.1, `>` y `Out-File` escriben UTF-16 y `Set-Content` escribe ANSI: no los uses para archivos del repositorio, o pasa `-Encoding utf8`.
  - La consola de Windows puede mostrar mal el UTF-8; no es un cambio del archivo. Se arregla con `chcp 65001` o con `[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()`.
  - No reescribas archivos completos desde Windows, para no ensuciar el historial; git desde WSL evita el resto del problema.

Si eres un agente que corre en WSL, puedes editar archivos y usar `git`, pero la compilación y la prueba de reproducción de la versión de Windows las hace el usuario en Windows nativo; no afirmes que compilaron si no lo viste.

## Idioma, *commits* y CHANGELOG

Resumen de lo esencial; si `rules` está disponible, sus procedimientos prevalecen.

- **Documentación y especificaciones:** español de México, sin anglicismos innecesarios, con comillas angulares «». Las palabras clave de OpenSpec (`SHALL`, `MUST`, `WHEN`, `THEN`) se dejan en inglés. El código y sus comentarios pueden seguir el estilo del archivo que se edita.
- **Mensajes de *commit*:** inglés internacional (UK), formato Conventional Commits (`feat`, `fix`, `docs`, `refactor`, `chore`), con un cuerpo de viñetas que describa cambios concretos. *Commits* atómicos: un cambio lógico cada uno, con `git add -- <archivos>` y sin `git add .` cuando se mezclan tipos.
- **No mencionar el CHANGELOG** en el cuerpo de un *commit*.
- **CHANGELOG.md:** un bloque por fecha, `## [AAAA-MM-DD] - Título descriptivo`, con la fecha en hora del centro de México (UTC-6). Viñetas `tipo: descripción en español`, sin subencabezados, con la más reciente arriba, sin líneas en blanco entre viñetas y solo añadiendo (no se editan viñetas existentes). El `CHANGELOG.md` va en el último *commit* de cada serie.
- **Identidad de Git:** la del autor ya está configurada en su máquina. No cambies `user.name`, `user.email` ni el remoto. Si falta, pide la identidad al usuario.
- **Publicar:** no hagas `git push` sin que el usuario lo haya pedido.
- **Pull requests:** un PR que no pase `check-pr.sh` se rechaza sin revisar el código. El *script* vive en el repositorio de reglas (`~/rules/scripts/check-pr.sh`, con la *skill* `/pr-check` y las reglas en `~/rules/rulesets/PR_CHECK.md`); este repositorio solo aporta su configuración en `.github/pr-check.conf`. Córrelo antes de abrirlo: `~/rules/scripts/check-pr.sh --base origin/main` (con `bash`; en Windows, desde WSL o Git Bash). Comprueba el formato de los *commits*, las reglas del CHANGELOG, que no haya archivos ajenos y que OpenSpec valide. Usa la plantilla de `.github/PULL_REQUEST_TEMPLATE.md` y no quites ninguna de sus secciones. Las reglas se aplican con tu propio entorno e identidad: lo que se revisa es el resultado, no la herramienta.
