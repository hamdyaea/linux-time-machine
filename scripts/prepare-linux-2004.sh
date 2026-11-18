#!/usr/bin/env bash
# Prepare a genuine Ubuntu 4.10 Warty Warthog i386 installation in QEMU.
# This only prepares the local VM; browser integration follows a verified boot.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$ROOT/.work/linux-2004"
ISO="${1:-$WORK/warty-release-install-i386.iso}"
[[ -s "$ISO" ]] || {
  echo "Missing Ubuntu 4.10 installation ISO: $ISO" >&2
  echo "Download from https://old-releases.ubuntu.com/releases/4.10/warty-release-install-i386.iso" >&2
  exit 2
}
for cmd in qemu-system-i386 qemu-img; do
  command -v "$cmd" >/dev/null || { echo "Missing command: $cmd" >&2; exit 1; }
done
mkdir -p "$WORK"
DISK="$WORK/ubuntu-4.10.qcow2"
if [[ ! -e "$DISK" ]]; then
  qemu-img create -f qcow2 "$DISK" 1G
fi
echo "Ubuntu 4.10 installer. Install to /dev/hda ONLY (QEMU virtual disk)."
echo "Choose a minimal package selection to keep the compressed browser image small."
echo "Ubuntu uses a normal user account; configure demo credentials during installation."
echo "After installation, boot without the CD to verify uname -a and /etc/issue."
exec qemu-system-i386 -machine pc -m 128 -cpu pentium2 -accel tcg \
  -vga std -nic none \
  -drive "if=ide,index=0,format=qcow2,file=$DISK" \
  -drive "if=ide,index=2,media=cdrom,format=raw,file=$ISO,readonly=on" \
  -boot order=d -no-reboot
