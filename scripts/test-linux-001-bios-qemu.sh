#!/usr/bin/env bash
# Reproduce the browser's BIOS floppy + IDE boot using QEMU, not -kernel.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLOPPY="$ROOT/images/linux-0.01-floppy.img"
DISK="$ROOT/images/linux-0.01-hda.img"
command -v qemu-system-i386 >/dev/null || { echo "Install QEMU: sudo pacman -S qemu-desktop" >&2; exit 1; }
[[ -s "$FLOPPY" && -s "$DISK" ]] || { echo "Missing local floppy or raw IDE image" >&2; exit 1; }
echo "=== Boot media ==="
file "$FLOPPY" "$DISK"
stat -c '%n: %s bytes' "$FLOPPY" "$DISK"
sha256sum "$FLOPPY" "$DISK"
echo
echo "=== QEMU BIOS boot: floppy first, IDE root disk attached ==="
echo "This intentionally does NOT use -kernel; it tests the same boot path as v86."
echo "Close the QEMU window to exit. No disk changes will be saved."
exec qemu-system-i386 \
 -machine pc \
 -m 8 \
 -cpu 486 \
 -accel tcg \
 -drive "file=$FLOPPY,format=raw,if=floppy,readonly=on" \
 -drive "file=$DISK,format=raw,if=ide,index=0,snapshot=on" \
 -boot order=a \
 -no-reboot
