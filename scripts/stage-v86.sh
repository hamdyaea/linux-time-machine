#!/usr/bin/env bash
# Copy an already-built v86 runtime into the Linux Time Machine static tree.
# Usage: bash scripts/stage-v86.sh /path/to/v86
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
V86="${1:?Usage: bash scripts/stage-v86.sh /path/to/v86}"
DEST="$ROOT/vendor/v86"
mkdir -p "$DEST"
for pair in "build/libv86.js:libv86.js" "build/v86.wasm:v86.wasm" "bios/seabios.bin:seabios.bin" "bios/vgabios.bin:vgabios.bin"; do
 src="${pair%%:*}"; dst="${pair#*:}"
 if [[ ! -s "$V86/$src" ]]; then echo "Missing $V86/$src; build v86 first" >&2; exit 1; fi
 cp "$V86/$src" "$DEST/$dst"
done
echo "v86 staged at $DEST"
ls -lh "$DEST"
echo "Now run: python3 -m http.server 8000"
echo "Open: http://localhost:8000/vm.html"
