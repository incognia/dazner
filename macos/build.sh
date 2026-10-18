#!/usr/bin/env bash
# Compila DAZNer para macOS y lo firma de forma local.
# Uso: ./build.sh            compila y firma
#      ./build.sh --open     además abre la aplicación
set -euo pipefail

cd "$(dirname "$0")"

# La carpeta del ejecutable está ignorada por git, así que no existe en un clon nuevo
mkdir -p DAZNer.app/Contents/MacOS

swiftc -O DAZNer.swift -o DAZNer.app/Contents/MacOS/DAZNer
codesign --force --sign - DAZNer.app

echo "Listo: $(pwd)/DAZNer.app"

if [[ "${1:-}" == "--open" ]]; then
    open -n DAZNer.app
fi
