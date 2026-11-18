#!/usr/bin/env bash
# Stage 1: verify an Alpine x86 ISO boots in QEMU. Does not alter production.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/.work/linux-2004-alpine"
mkdir -p "$OUT"
VERSION="3.21.3"
ISO_NAME="alpine-standard-${VERSION}-x86.iso"
ISO="$OUT/$ISO_NAME"
MIRRORS=(
  "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86"
  "https://mirror.init7.net/alpine/v3.21/releases/x86"
)
for cmd in curl sha256sum qemu-system-i386; do
  command -v "$cmd" >/dev/null || { echo "Missing command: $cmd" >&2; exit 1; }
done
verified=0
for base in "${MIRRORS[@]}"; do
  echo "Checking: $base"
  if ! curl -fLsS --connect-timeout 10 --max-time 60 "$base/$ISO_NAME.sha256" -o "$OUT/checksum.tmp"; then
    continue
  fi
  expected="$(grep -Eo '[a-fA-F0-9]{64}' "$OUT/checksum.tmp" | head -n1)"
  [[ -n "$expected" ]] || continue
  if [[ ! -s "$ISO" ]]; then
    curl -fLsS --retry 2 --connect-timeout 10 --max-time 900 "$base/$ISO_NAME" -o "$ISO.tmp" || continue
    mv "$ISO.tmp" "$ISO"
  fi
  actual="$(sha256sum "$ISO" | awk '{print $1}')"
  if [[ "${actual,,}" == "${expected,,}" ]]; then
    verified=1
    break
  fi
  echo "Checksum mismatch for $base" >&2
  rm -f "$ISO"
done
[[ "$verified" == 1 ]] || { echo "No verified Alpine ISO available." >&2; exit 1; }
echo "Verified Alpine x86 ISO: $(du -h "$ISO" | cut -f1)"
echo "Stage 1: Alpine boot test only; graphical Ubuntu 2004 theme is not installed yet."
exec qemu-system-i386 -machine pc -m 256 -vga std -nic user -cdrom "$ISO" -boot d
