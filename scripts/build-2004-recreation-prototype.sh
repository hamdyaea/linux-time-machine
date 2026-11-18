#!/usr/bin/env bash
# Experimental Tiny Core 15.0 Ubuntu-2004-style desktop ISO.
# Not authentic Ubuntu 4.10. Keeps original ISO and public site unchanged.
set -Eeuo pipefail
# Repacking a Linux initramfs requires root to preserve /dev device nodes.
if [[ "$EUID" -ne 0 ]]; then
  sudo -- bash "$0" --build-only
  echo "Starting QEMU as the regular user. Close the window with the title-bar X."
  exec qemu-system-i386 -machine pc -m 128 -vga std -nic none \
    -cdrom "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.work/linux-2004-recreation/Ubuntu-2004-recreation-test.iso" -boot d
fi
[[ "${1:-}" == "--build-only" ]] || {
  echo "Run this script as your normal user, not via sudo." >&2
  exit 1
}
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$ROOT/.work/linux-2004-recreation"
ISO="$WORK/TinyCore-15.0.iso"
DEST="$WORK/Ubuntu-2004-recreation-test.iso"
[[ -s "$ISO" ]] || { echo "Missing $ISO; run test-2004-recreation.sh first" >&2; exit 1; }
for cmd in xorriso gzip cpio find qemu-system-i386; do
  command -v "$cmd" >/dev/null || { echo "Missing command: $cmd" >&2; exit 1; }
done
TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT
mkdir -p "$TMP/iso" "$TMP/root"
xorriso -osirrox on -indev "$ISO" -extract / "$TMP/iso" >/dev/null 2>&1
[[ -f "$TMP/iso/boot/core.gz" ]] || { echo "Missing boot/core.gz" >&2; exit 1; }
(
 cd "$TMP/root"
 gzip -dc "$TMP/iso/boot/core.gz" | cpio -idm --no-absolute-filenames --quiet
)
# Tiny Core runs executable scripts under ~/.X.d during X startup.
# This proof-of-concept changes the root background and adds a desktop note.
mkdir -p "$TMP/root/home/tc/.X.d" "$TMP/root/home/tc"
cat > "$TMP/root/home/tc/.X.d/90-ubuntu2004-demo" <<'SH'
#!/bin/sh
# Cosmetic reconstruction; intentionally no claim to run Ubuntu 4.10.
command -v xsetroot >/dev/null 2>&1 && xsetroot -solid '#6b4534' || true
if command -v aterm >/dev/null 2>&1; then
  aterm -geometry 78x15+70+70 -title 'Linux Time Machine - Ubuntu 2004 recreation' \
    -e /bin/sh -c 'printf "\\n Ubuntu 4.10 (2004) - visual recreation\\n Base: Tiny Core Linux 15.0\\n This is NOT the original Ubuntu 4.10.\\n\\n"; exec /bin/sh' &
fi
SH
chmod 755 "$TMP/root/home/tc/.X.d/90-ubuntu2004-demo"
# Set ownership for user tc (UID/GID 1001 on standard Tiny Core).
chown -R 1001:50 "$TMP/root/home/tc/.X.d"
(
 cd "$TMP/root"
 find . -print0 | cpio --null -o -H newc --quiet | gzip -9 > "$TMP/iso/boot/core.gz"
)
# Skip the original Tiny Core blue boot menu and boot immediately.
# Preserve the existing kernel/initrd boot entries.
CFG="$TMP/iso/boot/isolinux/isolinux.cfg"
if [[ -f "$CFG" ]]; then
  sed -i -E '/^[[:space:]]*(PROMPT|prompt|TIMEOUT|timeout|ONTIMEOUT|ontimeout)[[:space:]]/Id' "$CFG"
  printf '\\nprompt 0\\ntimeout 0\\n' >> "$CFG"
fi
# Bootable BIOS ISO, with the existing isolinux loader.
xorriso -as mkisofs -quiet -R -J \
  -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -o "$DEST" "$TMP/iso"
chown "$(stat -c %u "$ISO")":"$(stat -c %g "$ISO")" "$DEST"
echo "Built: $DEST"
du -h "$ISO" "$DEST"
echo "ISO construction complete; returning to unprivileged launcher."
