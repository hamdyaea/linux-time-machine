#!/usr/bin/env bash
# Prepare an authentic 1993 Linux 0.99.12 + Slackware 1.01 QEMU test.
# Does NOT alter the working 1991 guest or deploy any site changes.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$ROOT/.work/linux-1993"
SRC="$WORK/linux-evocation"
ARCHIVE="$WORK/qemu-xmas-slackware.tar.xz"
mkdir -p "$WORK"
for cmd in git docker qemu-system-i386 qemu-img curl tar xz; do
  command -v "$cmd" >/dev/null || { echo "Missing command: $cmd" >&2; exit 1; }
done
docker info >/dev/null 2>&1 || { echo "Docker daemon is unavailable" >&2; exit 1; }
if [[ ! -d "$SRC/.git" ]]; then
  git clone --depth=1 https://github.com/freewilll/linux-evocation.git "$SRC"
fi
echo "Building the 1993 kernel with a reproducible 32-bit Ubuntu toolchain..."
docker run --rm --platform linux/amd64 -v "$SRC:/src" -w /src ubuntu:20.04 bash -euc '
 export DEBIAN_FRONTEND=noninteractive
 apt-get update -qq
 apt-get install -y -qq --no-install-recommends build-essential bin86 bc libc6-dev-i386 gcc-multilib make binutils >/dev/null
 if [[ ! -f .config ]]; then
   echo "No kernel .config found. Run make config interactively in the container before building." >&2
   exit 3
 fi
 make dep
 make -j2
 test -s zImage
'
if [[ ! -s "$ARCHIVE" ]]; then
  curl -fL --retry 3 -o "$ARCHIVE.part" "https://www.qemu-advent-calendar.org/2014/download/qemu-xmas-slackware.tar.xz"
  mv "$ARCHIVE.part" "$ARCHIVE"
fi
mkdir -p "$WORK/extracted"
tar -xJf "$ARCHIVE" -C "$WORK/extracted"
DISK="$(find "$WORK/extracted" -type f -name 'slackware.qcow2.xz' -print -quit)"
if [[ -n "$DISK" ]]; then xz -dk "$DISK"; fi
DISK="$(find "$WORK/extracted" -type f -name 'slackware.qcow2' -print -quit)"
[[ -n "$DISK" ]] || { echo "Slackware qcow2 image not found in archive" >&2; exit 1; }
FLOPPY="$WORK/linux-0.99.12-floppy.img"
truncate -s 1474560 "$FLOPPY"
dd if="$SRC/zImage" of="$FLOPPY" conv=notrunc status=none
# Linux 0.99 boot protocol: bytes 508-509 encode /dev/hda1 (major 3, minor 1).
printf '\\x01\\x03' | dd of="$FLOPPY" bs=1 seek=508 conv=notrunc status=none
echo "Ready for local QEMU validation (NOT yet browser-tested):"
echo "  qemu-system-i386 -machine pc -m 16 -cpu pentium2 -nic none -drive if=floppy,format=raw,file='$FLOPPY' -drive if=ide,index=0,format=qcow2,file='$DISK',snapshot=on -boot order=a"
echo "Only after QEMU succeeds: convert the qcow2 to raw, compress and test v86."
