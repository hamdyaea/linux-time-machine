#!/usr/bin/env bash
# Manage persistent Alpine-based era reconstructions without modifying the master disk.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIR="$ROOT/.work/linux-2004-alpine"
MASTER="$DIR/alpine-2004.qcow2"
BASE="$DIR/alpine-master.qcow2"
YEARS=(2004 2006 2008 2010 2012 2014 2016 2018 2020 2022 2024 2026)
usage() {
  cat <<'HELP'
Usage:
  bash scripts/manage-alpine-era-disks.sh snapshot-master
  bash scripts/manage-alpine-era-disks.sh create YEAR
  bash scripts/manage-alpine-era-disks.sh boot YEAR
  bash scripts/manage-alpine-era-disks.sh list

Stop QEMU completely before snapshot-master or create.
snapshot-master copies the working 2004 disk to an immutable master baseline.
create makes a FULL independent qcow2 copy, safe to move/export later.
boot starts the requested disk with serial console and USB tablet.
HELP
}
require_disk() { [[ -s "$1" ]] || { echo "Missing disk: $1" >&2; exit 1; }; }
check_year() {
  local ok=0 y
  for y in "${YEARS[@]}"; do [[ "$y" == "$1" ]] && ok=1; done
  [[ "$ok" == 1 ]] || { echo "Unsupported year: $1. Choose: ${YEARS[*]}" >&2; exit 2; }
}
for cmd in qemu-img qemu-system-i386; do
  command -v "$cmd" >/dev/null || { echo "Missing command: $cmd" >&2; exit 1; }
done
mkdir -p "$DIR"
action="${1:-}"
case "$action" in
  snapshot-master)
    require_disk "$MASTER"
    [[ ! -e "$BASE" ]] || { echo "Master already exists: $BASE (refusing overwrite)" >&2; exit 1; }
    echo "Make sure QEMU is completely stopped. Copying $MASTER..."
    qemu-img convert -p -f qcow2 -O qcow2 "$MASTER" "$BASE"
    chmod a-w "$BASE"
    echo "Master saved: $BASE"
    ;;
  create)
    year="${2:-}"; check_year "$year"
    require_disk "$BASE"
    target="$DIR/alpine-era-$year.qcow2"
    [[ ! -e "$target" ]] || { echo "Era disk already exists: $target (refusing overwrite)" >&2; exit 1; }
    qemu-img convert -p -f qcow2 -O qcow2 "$BASE" "$target"
    echo "Independent era disk created: $target"
    ;;
  boot)
    year="${2:-}"; check_year "$year"
    target="$DIR/alpine-era-$year.qcow2"
    require_disk "$target"
    exec qemu-system-i386 -machine pc -m 1024 -vga std -device qemu-xhci -device usb-tablet \
      -nic user,hostfwd=tcp:127.0.0.1:2222-:22 \
      -drive "file=$target,format=qcow2,if=ide" -boot c -serial mon:stdio
    ;;
  list)
    ls -lh "$DIR"/alpine-{2004,master,era-*}.qcow2 2>/dev/null || true
    ;;
  *) usage; exit 2 ;;
esac
