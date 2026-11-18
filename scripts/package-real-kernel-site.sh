#!/usr/bin/env bash
# Prepare a self-contained static deployment including the historical Linux guest.
# Does not deploy; upload the generated directory to your static host.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/.work/pages-dist}"
if [[ "$OUT" == "$ROOT" ]]; then echo "Refusing to overwrite repository root" >&2; exit 1; fi
for file in \
 "$ROOT/images/linux-0.01-floppy.img" \
 "$ROOT/images/linux-0.01-hda.img.gz" \
 "$ROOT/vendor/v86/libv86.js" \
 "$ROOT/vendor/v86/v86.wasm" \
 "$ROOT/vendor/v86/seabios.bin" \
 "$ROOT/vendor/v86/vgabios.bin"; do
 if [[ ! -s "$file" ]]; then echo "Missing boot asset: $file" >&2; exit 1; fi
done
python3 - "$ROOT/images/linux-0.01-floppy.img" "$ROOT/images/linux-0.01-floppy-1440k.img" <<'PY'
from pathlib import Path
import sys
src, dst = map(Path, sys.argv[1:])
data = src.read_bytes()
if len(data) > 1474560 or data[510:512] != bytes.fromhex("55aa"):
    raise SystemExit("Invalid boot image or image exceeds 1.44 MB")
dst.write_bytes(data.ljust(1474560, bytes([0])))
print("Padded boot floppy:", dst, dst.stat().st_size)
PY
mkdir -p "$OUT/images" "$OUT/vendor/v86" "$OUT/assets"
# v86 only instantiates an IDE channel if its master exists. The real historical
# disk must remain the primary slave (index=1), so supply a blank master.
truncate -s 1048576 "$OUT/images/linux-0.01-ide-master-placeholder.img"
# Remove the oversized raw disk from any previous build; Pages rejects files >25 MiB.
rm -f "$OUT/images/linux-0.01-hda.img"
for file in index.html about.html developer.html vm.html vm.js vm-diagnostics.js app.js eras.js style.css _headers LICENSE; do
 [[ -f "$ROOT/$file" ]] && cp "$ROOT/$file" "$OUT/$file"
done
cp -a "$ROOT/assets/." "$OUT/assets/"
cp "$ROOT/images/linux-0.01-floppy-1440k.img" "$ROOT/images/linux-0.01-hda.img.gz" "$OUT/images/"
cp "$ROOT/vendor/v86/"{libv86.js,v86.wasm,seabios.bin,vgabios.bin} "$OUT/vendor/v86/"
cp "$ROOT/guests.json" "$OUT/guests.json"
# Optional authentic 1993 guest. Do not break 1991-only builds when not prepared.
SLACKWARE_QCOW="$ROOT/.work/linux-1993/extracted/qemu-xmas-slackware/slackware.qcow2"
FLOPPY_1993="$ROOT/.work/linux-1993/linux-0.99.12-floppy.img"
rm -f "$OUT/images/linux-0.99.12-floppy.img" "$OUT/images/slackware-1.01-1993.raw.gz" "$OUT"/images/slackware-1.01-1993.raw.gz.part-*
if [[ -s "$SLACKWARE_QCOW" && -s "$FLOPPY_1993" ]]; then
 command -v qemu-img >/dev/null || { echo "qemu-img required for 1993 guest" >&2; exit 1; }
 cp "$FLOPPY_1993" "$OUT/images/linux-0.99.12-floppy.img"
 # qemu-img needs a seekable destination; use a temporary sparse raw image.
 RAW_1993="$ROOT/.work/linux-1993/slackware-1993.tmp.raw"
 qemu-img convert -f qcow2 -O raw -S 4k "$SLACKWARE_QCOW" "$RAW_1993"
 gzip -n -9 -c "$RAW_1993" > "$OUT/images/slackware-1.01-1993.raw.gz"
 rm -f "$RAW_1993"
 if [[ ! -s "$OUT/images/slackware-1.01-1993.raw.gz" ]]; then echo "1993 disk compression failed" >&2; exit 1; fi
 echo "1993 compressed disk: $(du -h "$OUT/images/slackware-1.01-1993.raw.gz")"
 # Cloudflare Pages limits each individual asset to 25 MiB.
 # Split the compressed gzip byte stream; the browser reassembles before decompression.
 split -b 20m -d -a 3 "$OUT/images/slackware-1.01-1993.raw.gz" "$OUT/images/slackware-1.01-1993.raw.gz.part-"
 rm -f "$OUT/images/slackware-1.01-1993.raw.gz"
 echo "1993 disk split into $(find "$OUT/images" -maxdepth 1 -name 'slackware-1.01-1993.raw.gz.part-*' | wc -l) Cloudflare-safe parts"
else
 echo "1993 guest assets missing. Run scripts/prepare-linux-1993.sh first; 1993 browser boot will not be available." >&2
fi
REDHAT_QCOW="$ROOT/.work/linux-1998/redhat-5.2-small.qcow2"
rm -f "$OUT"/images/redhat-5.2-1998.raw.gz.part-*
if [[ -s "$REDHAT_QCOW" ]]; then
 REDHAT_BYTES="$(qemu-img info --output=json "$REDHAT_QCOW" | python3 -c 'import json,sys; print(json.load(sys.stdin)["virtual-size"])')"
 if (( REDHAT_BYTES >= 2147483648 )); then echo "ERROR: Red Hat virtual disk must be smaller than 2 GiB for browser Blob compatibility" >&2; exit 1; fi
 RAW_1998="$ROOT/.work/linux-1998/redhat-1998.tmp.raw"
 qemu-img convert -f qcow2 -O raw -S 4k "$REDHAT_QCOW" "$RAW_1998"
 gzip -n -9 -c "$RAW_1998" | split -b 20m -d -a 3 - "$OUT/images/redhat-5.2-1998.raw.gz.part-"
 rm -f "$RAW_1998"
 echo "1998 disk split into $(find "$OUT/images" -maxdepth 1 -name 'redhat-5.2-1998.raw.gz.part-*' | wc -l) parts"
else
 echo "1998 compact guest not found at $REDHAT_QCOW; skipping Red Hat image." >&2
fi
(
 cd "$OUT"
 sha256sum images/linux-0.01-floppy-1440k.img images/linux-0.01-ide-master-placeholder.img images/linux-0.01-hda.img.gz vendor/v86/{libv86.js,v86.wasm,seabios.bin,vgabios.bin} > SHA256SUMS
 if [[ -s images/redhat-5.2-1998.raw.gz.part-000 ]]; then sha256sum images/redhat-5.2-1998.raw.gz.part-* >> SHA256SUMS; fi
 if [[ -s images/slackware-1.01-1993.raw.gz.part-000 ]]; then sha256sum images/linux-0.99.12-floppy.img images/slackware-1.01-1993.raw.gz.part-* >> SHA256SUMS; fi
)
if find "$OUT" -type f -size +25M -print | grep -q .; then
 echo "ERROR: Bundle contains a file larger than 25 MiB:" >&2
 find "$OUT" -type f -size +25M -print >&2
 exit 1
fi
echo "Static bundle ready: $OUT"
du -sh "$OUT"
echo "Test: cd '$OUT' && python3 -m http.server 8000"
echo "Cloudflare Pages Git builds do not include gitignored binary assets automatically."
echo "Publish this bundled directory using a compatible Cloudflare Pages direct-upload workflow after browser boot is validated."
