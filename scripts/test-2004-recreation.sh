#!/usr/bin/env bash
# Prototype only: do not replace the live Ubuntu 4.10 guest.
# Tiny Core Linux x86 is a lightweight, real graphical Linux base for a
# clearly labelled 2004-style reconstruction, NOT authentic Ubuntu 4.10.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/.work/linux-2004-recreation"
BASE="https://tinycorelinux.net/15.x/x86/release"
ISO="$OUT/TinyCore-current.iso"
mkdir -p "$OUT"
for cmd in curl md5sum qemu-system-i386; do
  command -v "$cmd" >/dev/null || { echo "Missing command: $cmd" >&2; exit 1; }
done
if [[ ! -s "$ISO" ]]; then
  curl -fL --retry 3 --connect-timeout 20 "$BASE/TinyCore-current.iso" -o "$ISO.tmp"
  mv "$ISO.tmp" "$ISO"
fi
# Prefer upstream checksum when available; fail rather than boot unverified data.
curl -fL --retry 3 "$BASE/TinyCore-current.iso.md5.txt" -o "$OUT/upstream.md5"
expected="$(grep -Eo '[a-fA-F0-9]{32}' "$OUT/upstream.md5" | head -n 1)"
[[ -n "$expected" ]] || { echo "Cannot parse upstream MD5 checksum" >&2; exit 1; }
actual="$(md5sum "$ISO" | awk '{print $1}')"
[[ "${actual,,}" == "${expected,,}" ]] || { echo "ISO checksum mismatch" >&2; exit 1; }
echo "Verified Tiny Core ISO: $(du -h "$ISO" | cut -f1)"
echo "Prototype only: Tiny Core desktop is NOT yet themed as Ubuntu 4.10."
echo "Test graphical boot and mouse/keyboard, then close QEMU."
exec qemu-system-i386 -machine pc -m 128 -vga std -nic none -cdrom "$ISO" -boot d
