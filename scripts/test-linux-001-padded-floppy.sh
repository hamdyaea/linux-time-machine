#!/usr/bin/env bash
# Preserve the original Linux 0.01 boot image, padding it to a BIOS 1.44 MB floppy.
# boot/boot.s explicitly assumes 18 sectors/track, 2 heads, 80 cylinders.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/images/linux-0.01-floppy.img"
OUT="$ROOT/images/linux-0.01-floppy-1440k.img"
[[ -s "$SRC" ]] || { echo "Missing $SRC" >&2; exit 1; }
python3 - "$SRC" "$OUT" <<'PY'
import pathlib, sys
src, out = map(pathlib.Path, sys.argv[1:])
data = src.read_bytes()
capacity = 80 * 2 * 18 * 512
if len(data) > capacity:
    raise SystemExit(f"Image too large: {len(data)} > {capacity}")
if data[510:512] != bytes.fromhex("55aa"):
    raise SystemExit("Missing BIOS boot signature at offset 510")
out.write_bytes(data.ljust(capacity, bytes([0])))
print(f"Original: {len(data)} bytes")
print(f"Padded:   {out} ({out.stat().st_size} bytes)")
print("Boot sector and kernel bytes preserved; original file untouched.")
PY
echo
echo "Boot padded floppy with QEMU BIOS:"
echo "  qemu-system-i386 -machine pc -m 8 -cpu 486 -accel tcg \\"
echo "    -drive file=$OUT,format=raw,if=floppy,readonly=on \\"
echo "    -drive file=$ROOT/images/linux-0.01-hda.img,format=raw,if=ide,index=0,snapshot=on \\"
echo "    -boot order=a -no-reboot -no-shutdown"
