#!/usr/bin/env bash
# Prepare a self-contained static deployment including the historical Linux guest.
# Does not deploy; upload the generated directory to your static host.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/.work/pages-dist}"
if [[ "$OUT" == "$ROOT" ]]; then echo "Refusing to overwrite repository root" >&2; exit 1; fi
for file in \
 "$ROOT/images/linux-0.01-floppy.img" \
 "$ROOT/images/linux-0.01-hda.img" \
 "$ROOT/vendor/v86/libv86.js" \
 "$ROOT/vendor/v86/v86.wasm" \
 "$ROOT/vendor/v86/seabios.bin" \
 "$ROOT/vendor/v86/vgabios.bin"; do
 if [[ ! -s "$file" ]]; then echo "Missing boot asset: $file" >&2; exit 1; fi
done
mkdir -p "$OUT/images" "$OUT/vendor/v86" "$OUT/assets"
for file in index.html about.html developer.html vm.html vm.js app.js eras.js style.css _headers LICENSE; do
 [[ -f "$ROOT/$file" ]] && cp "$ROOT/$file" "$OUT/$file"
done
cp -a "$ROOT/assets/." "$OUT/assets/"
cp "$ROOT/images/linux-0.01-floppy.img" "$ROOT/images/linux-0.01-hda.img" "$OUT/images/"
cp "$ROOT/vendor/v86/"{libv86.js,v86.wasm,seabios.bin,vgabios.bin} "$OUT/vendor/v86/"
cp "$ROOT/guests.json" "$OUT/guests.json"
(
 cd "$OUT"
 sha256sum images/linux-0.01-floppy.img images/linux-0.01-hda.img vendor/v86/{libv86.js,v86.wasm,seabios.bin,vgabios.bin} > SHA256SUMS
)
echo "Static bundle ready: $OUT"
du -sh "$OUT"
echo "Test: cd '$OUT' && python3 -m http.server 8000"
echo "Cloudflare Pages Git builds do not include gitignored binary assets automatically."
echo "Publish this bundled directory using a compatible Cloudflare Pages direct-upload workflow after browser boot is validated."
