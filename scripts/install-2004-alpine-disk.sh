#!/usr/bin/env bash
# Create and boot a persistent Alpine x86 test disk for the 2004 reconstruction.
# First run: install Alpine from ISO with setup-alpine/setup-disk.
# Later runs: boot the installed disk without the ISO.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/.work/linux-2004-alpine"
ISO="$OUT/alpine-standard-3.21.3-x86.iso"
DISK="$OUT/alpine-2004.qcow2"
MODE="${1:-install}"
for cmd in qemu-system-i386 qemu-img; do
  command -v "$cmd" >/dev/null || { echo "Missing command: $cmd" >&2; exit 1; }
done
mkdir -p "$OUT"
if [[ ! -e "$DISK" ]]; then
  qemu-img create -f qcow2 "$DISK" 4G
fi
args=(-machine pc -m 1024 -vga std -nic user,hostfwd=tcp:127.0.0.1:2222-:22
      -drive "file=$DISK,format=qcow2,if=ide" -serial mon:stdio)
case "$MODE" in
  install)
    [[ -s "$ISO" ]] || { echo "Missing ISO: $ISO (run scripts/test-2004-alpine.sh first)" >&2; exit 1; }
    echo "INSTALL MODE: Alpine live ISO + persistent /dev/sda disk."
    echo "Inside Alpine serial console: setup-alpine; select sda, mode sys."
    echo "IMPORTANT: /dev/sda is the virtual disk, not your host drive."
    echo "After install, shut down QEMU and rerun: bash $0 boot"
    exec qemu-system-i386 "${args[@]}" -cdrom "$ISO" -boot d
    ;;
  boot)
    echo "BOOT MODE: persistent Alpine disk $DISK"
    exec qemu-system-i386 "${args[@]}" -boot c
    ;;
  *)
    echo "Usage: $0 [install|boot]" >&2
    exit 2
    ;;
esac
