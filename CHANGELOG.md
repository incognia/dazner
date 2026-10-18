# Historial de cambios

**Nota:** Todas las fechas están en zona horaria CST de Ciudad de México (UTC-6).

<!-- markdownlint-disable MD013 MD024 MD022 MD032 -->
## [2026-10-18] - Primera versión de DAZNer, visor nativo de DAZN con WebKit

- docs: actualiza `README.md` con la compilación mediante `macos/build.sh`, las rutas nuevas (`macos/` y `shared/`) en los comandos de ícono, instancias y diagnóstico, y una sección «Estructura del repositorio»; ajusta las rutas del ícono en `NOTICE.md` y marca la fase 0 como hecha en `ROADMAP.md`
- feat: agrega `macos/build.sh`, que compila con `swiftc`, firma la aplicación de forma local y, con `--open`, la abre; crea la carpeta del ejecutable porque `.gitignore` la excluye y no existe en un clon nuevo
- refactor: reorganiza el repositorio por plataforma (fase 0 de `ROADMAP.md`): `DAZNer.swift` y `DAZNer.app` pasan a `macos/`, y `assets/` y `scripts/make-icon.swift` pasan a `shared/`; `.gitignore` y el uso de `make-icon.swift` apuntan a las rutas nuevas
- docs: actualiza `ROADMAP.md` con la decisión de usar el lenguaje nativo de cada plataforma (Swift en macOS, C# con WPF en Windows, C++/QML con CMake en Qt y Vala/C con Meson en GTK), los enlaces de Vala verificados, Rust como alternativa descartada por ahora y el riesgo de mantener cuatro bases de código
- docs: agrega `ROADMAP.md` con la hoja de ruta para llevar DAZNer a Windows (WebView2) y a Linux (Qt WebEngine como prioridad y WebKitGTK como variante experimental), con la reorganización del repositorio por plataforma, la extracción del *script* de pantalla completa a `shared/`, los datos confirmados sobre el DRM, la tabla de funciones por plataforma y los riesgos
- docs: agrega `assets/social-preview.png` (1280×640 px), la imagen de vista previa que GitHub muestra al compartir el repositorio en redes sociales
- docs: ajusta el `README.md` al formato de GitHub (*frontmatter*, marca de tiempo), agrega los *badges* de licencia GPLv3, plataforma, Swift y WebKit, y una sección «Licencia» con enlaces a `LICENSE` y `NOTICE.md`
- chore: agrega `.gitignore` para no versionar el binario compilado, la firma que genera `codesign`, `debug.log` ni los `.DS_Store`
- feat: reemplaza el ícono de la aplicación, que era el logotipo de DAZN, por uno original (un balón de fútbol americano con un botón de reproducción); la imagen fuente queda en `assets/icon.png` y `scripts/make-icon.swift` genera `app.icns` con el cuerpo redondeado y el margen transparente de los íconos de macOS
- docs: agrega `NOTICE.md` con el aviso de proyecto no oficial y de marcas
- chore: se agrega, y queda comentada en el código, una medición del elemento y del color de fondo en los márgenes derecho e inferior durante la pantalla completa; sirvió para descartar un error, ya que la barra gris del borde derecho es el panel de estadísticas de DAZN
- feat: con dos paneles se deja un hueco de 8 px entre ellos, igual al que se ve entre los videos del *multiview* de DAZN (4 px de la cuadrícula más 2 px de borde por celda a cada lado, medido en tamaños de 1280×720 a 2478×1394); el hueco va dentro del ancho de la ventana y la proporción de 32:9 se conserva; el modo `--debug` mide además ese hueco
- fix: «Salir» (⌘Q) del menú de la aplicación estaba deshabilitado porque se le asignaba como destino el delegado, que no atiende `terminate:`; ahora lo atiende `NSApplication`
- feat: agrega al menú «Ventana» las acciones «Rellenar y centrar» (⌘F), que agranda la ventana al máximo que cabe en la pantalla conservando la proporción de 16:9 o 32:9 y la centra
- chore: el identificador de la aplicación pasa de `com.kabatone.daznmv` a `mx.org.faraday.dazner` (dominio personal faraday.org.mx al revés) y se copian los datos de la sesión guardada (`WebKit`, `Caches` y cookies) al nombre nuevo para no tener que iniciar sesión otra vez
- docs: agrega `README.md` con compilación, uso, modo de diagnóstico y notas
- docs: agrega el archivo `LICENSE` con la licencia GPLv3
- feat: el modo `--debug` registra además los eventos de cada panel (cambio de tamaño, descarga y carga de la página) para distinguir un refresco real de un simple redibujado
- fix: al abrir el segundo panel, el primero se refrescaba porque se achicaba y se volvía a agrandar mientras la ventana crecía; ahora la ventana cambia de tamaño primero, sin animación, y el panel abierto conserva el suyo
- feat: al volver a un panel se cierra el segundo (se detiene su carga, se quita de la ventana y se libera su `WKWebView`) y se reactiva el audio del panel que queda si estaba silenciado por no tener foco
- refactor: el menú ofrece solo uno y dos paneles (⌘1 y ⌘2); las opciones de tres y cuatro quedan comentadas para reutilizarlas, y el segundo panel se crea al elegirlo y no al arrancar
- feat: con dos paneles la ventana pasa a proporción 32:9 y se redimensiona sola conservando su esquina superior izquierda, y al volver a un panel regresa a 16:9
- chore: la aplicación y la carpeta del proyecto pasan a llamarse «DAZNer» (antes «DaznMV» y «dazn»), conservando el identificador interno `com.kabatone.daznmv` para no perder la sesión guardada; `debug.log` se escribe junto a la aplicación
- fix: la pantalla completa general con cuatro videos corría la cuadrícula 267 px a la derecha por un margen izquierdo que DAZN calcula para centrar el contenedor; ahora los márgenes y las posiciones se fijan en línea con `!important` y se restaura el estilo original al salir
- feat: agrega el modo de diagnóstico opcional `--debug`, que escribe `debug.log` y habilita el inspector web; está desactivado de forma predeterminada
- fix: la pantalla completa desde el botón de un video individual del *multiview* dejaba el reproductor vacío porque DAZN dejaba el contenedor padre con `opacity: 0` y reescribía sus clases; ahora se fuerza la opacidad de los contenedores, se oculta el resto de la página y un `MutationObserver` repone las marcas
- feat: la pantalla completa de DAZN llena la ventana o el panel sin pasar a la pantalla completa de macOS, interceptando la API de HTML5 con un *script* que estira el elemento; Esc regresa al modo normal
- fix: no se podía pegar la contraseña porque faltaba el menú «Edición», sin el cual macOS no enlaza ⌘C, ⌘V, ⌘X, ⌘A ni ⌘Z
- feat: agrega el ícono de la aplicación, tomado de la app «DAZN» que instaló Chrome
- fix: el temporizador de audio reactivaba el sonido del panel con foco cada segundo y anulaba el silencio puesto desde el reproductor; ahora solo silencia los paneles sin foco y reactiva el audio una vez al cambiar de panel
- feat: la ventana se redimensiona solo con proporción fija de 16:9
- fix: la ventana sin bordes no se podía arrastrar porque el contenido web cubría toda la superficie; se resuelve con una franja invisible de 14 px en el borde superior (el doble clic maximiza o restaura) y con ⌥ Option + arrastrar
- feat: primera versión de la aplicación nativa de macOS en un solo archivo de Swift con `WKWebView` (reproducción con DRM como en Safari), ventana sin bordes, de uno a cuatro paneles con audio solo en el panel con foco, atajos de teclado y sesión persistente compartida entre paneles e instancias
