#!/usr/bin/env bash
# Prototype only: do not replace the live Ubuntu 4.10 guest.
# Tiny Core Linux x86 is a lightweight, real graphical Linux base for a
# clearly labelled 2004-style reconstruction, NOT authentic Ubuntu 4.10.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/.work/linux-2004-recreation"
ISO="$OUT/TinyCore-current.iso"
mkdir -p "$OUT"
for cmd in curl md5sum qemu-system-i386; do
  command -v "$cmd" >/dev/null || { echo "Missing command: $cmd" >&2; exit 1; }
done
# Use upstream or a public mirror; some networks cannot reach tinycorelinux.net.
SOURCES=(
  "https://distro.ibiblio.org/tinycorelinux/15.x/x86/release"
  "http://tinycorelinux.net/15.x/x86/release"
  "https://tinycorelinux.net/15.x/x86/release"
)
download_from_mirror() {
  local base="$1" checksum expected actual
  echo "Trying Tiny Core mirror: $base"
  rm -f "$OUT/upstream.md5" "$ISO.tmp"
  curl -fLsS --retry 2 --connect-timeout 8 --max-time 180 \
    "$base/TinyCore-current.iso.md5.txt" -o "$OUT/upstream.md5" || return 1
  expected="$(grep -Eo '[a-fA-F0-9]{32}' "$OUT/upstream.md5" | head -n 1)"
  [[ -n "$expected" ]] || return 1
  if [[ ! -s "$ISO" ]]; then
    curl -fLsS --retry 2 --connect-timeout 8 --max-time 600 \
      "$base/TinyCore-current.iso" -o "$ISO.tmp" || return 1
    actual="$(md5sum "$ISO.tmp" | awk '{print $1}')"
    [[ "${actual,,}" == "${expected,,}" ]] || {
      echo "Checksum mismatch from $base" >&2
      rm -f "$ISO.tmp"
      return 1
    }
    mv "$ISO.tmp" "$ISO"
  else
    actual="$(md5sum "$ISO" | awk '{print $1}')"
    [[ "${actual,,}" == "${expected,,}" ]] || return 1
  fi
  return 0
}
verified=0
for base in "${SOURCES[@]}"; do
  if download_from_mirror "$base"; then verified=1; break; fi
done
[[ "$verified" == 1 ]] || {
  echo "No mirror yielded a checksum-verified ISO. Check connectivity and mirror URLs." >&2
  exit 1
}
echo "Verified Tiny Core ISO: $(du -h "$ISO" | cut -f1)"
echo "Prototype only: Tiny Core desktop is NOT yet themed as Ubuntu 4.10."
echo "Test graphical boot and mouse/keyboard, then close QEMU."
exec qemu-system-i386 -machine pc -m 128 -vga std -nic none -cdrom "$ISO" -boot d
