#!/usr/bin/env bash
# Read-only inspection of Tiny Core ISO before building a themed initramfs.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO="$ROOT/.work/linux-2004-recreation/TinyCore-15.0.iso"
[[ -s "$ISO" ]] || { echo "Missing ISO; run scripts/test-2004-recreation.sh first" >&2; exit 1; }
for cmd in bsdtar gzip cpio; do
  command -v "$cmd" >/dev/null || { echo "Missing: $cmd" >&2; exit 1; }
done
echo '===== ISO FILES ====='
bsdtar -tf "$ISO" | head -80
echo '===== BOOT FILES ====='
bsdtar -tf "$ISO" | grep -Ei '(vmlinuz|bzimage|core\.gz|isolinux|boot)' | head -60
echo '===== INITRAMFS CONTENTS ====='
# Tiny Core 15.x uses boot/core.gz; do not modify the ISO in this step.
if bsdtar -tf "$ISO" | grep -q '^boot/core.gz$'; then
  bsdtar -xOf "$ISO" boot/core.gz | gzip -dc | cpio -it 2>/dev/null | grep -E '(home/tc/|opt/bootlocal.sh|etc/skel/|usr/local/bin/)' | head -100 || true
else
  echo 'boot/core.gz not found: inspect the ISO listing above'
fi
echo 'Inspection complete; no images modified.'
