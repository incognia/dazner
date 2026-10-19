#!/usr/bin/env bash
# Compila DAZNer para macOS y lo firma de forma local.
# Uso: ./build.sh            compila y firma
#      ./build.sh --open     además abre la aplicación
set -euo pipefail

cd "$(dirname "$0")"

# La carpeta del ejecutable está ignorada por git, así que no existe en un clon nuevo
mkdir -p DAZNer.app/Contents/MacOS

swiftc -O DAZNer.swift -o DAZNer.app/Contents/MacOS/DAZNer

# El script de pantalla completa es común a todas las plataformas y vive en shared/.
# Se copia al paquete antes de firmar, porque la firma sella los recursos.
SHARED_SCRIPT="../shared/fill-fullscreen.js"
if [[ ! -f "$SHARED_SCRIPT" ]]; then
    echo "Falta $SHARED_SCRIPT: sin él la pantalla completa no se emula." >&2
    exit 1
fi
mkdir -p DAZNer.app/Contents/Resources
cp "$SHARED_SCRIPT" DAZNer.app/Contents/Resources/fill-fullscreen.js

codesign --force --sign - DAZNer.app

echo "Listo: $(pwd)/DAZNer.app"

if [[ "${1:-}" == "--open" ]]; then
    open -n DAZNer.app
fi
