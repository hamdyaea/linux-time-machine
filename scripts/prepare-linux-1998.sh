#!/usr/bin/env bash
# Stage a genuine 1998 Red Hat Linux 5.2 guest for local QEMU installation.
# Browser integration is deliberately deferred until the installed disk boots.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$ROOT/.work/linux-1998"
ISO="${1:-}"
[[ -n "$ISO" && -s "$ISO" ]] || {
 echo "Usage: bash scripts/prepare-linux-1998.sh /absolute/path/to/redhat-5.2-i386.iso" >&2
 echo "Provide a legally obtained, verified original Red Hat 5.2 installation ISO." >&2
 exit 2
}
for cmd in qemu-system-i386 qemu-img file; do
 command -v "$cmd" >/dev/null || { echo "Missing command: $cmd" >&2; exit 1; }
done
mkdir -p "$WORK"
DISK="$WORK/redhat-5.2.qcow2"
if [[ ! -e "$DISK" ]]; then
 qemu-img create -f qcow2 "$DISK" 2G
fi
echo "Starting local installation. Install Linux to the IDE disk /dev/hda."
echo "After installation, boot again without the ISO and verify uname -a."
exec qemu-system-i386 -machine pc -m 64 -cpu pentium2 -accel tcg \
 -vga cirrus -nic none \
 -drive "if=ide,index=0,format=qcow2,file=$DISK" \
 -drive "if=ide,index=2,media=cdrom,format=raw,file=$ISO,readonly=on" \
 -boot order=d -no-reboot
