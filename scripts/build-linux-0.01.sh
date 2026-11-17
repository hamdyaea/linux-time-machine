#!/usr/bin/env bash
# Build a real Linux 0.01-derived boot image using the independently maintained
# joeangel/linux-0.01 QEMU compatibility port. Requires Docker and Git.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${LINUX01_WORKDIR:-$ROOT/.work/linux-0.01}"
UPSTREAM="https://github.com/joeangel/linux-0.01.git"
mkdir -p "$(dirname "$WORK")" "$ROOT/images"
if ! command -v docker >/dev/null; then echo "Docker is required" >&2; exit 1; fi
if ! command -v git >/dev/null; then echo "Git is required" >&2; exit 1; fi
if [[ ! -d "$WORK/.git" ]]; then git clone "$UPSTREAM" "$WORK"; fi
(
 cd "$WORK"
 git fetch --tags origin
 make -f mvp.mk build
)
if [[ ! -s "$WORK/build/Image" ]]; then
 echo "No kernel image produced: $WORK/build/Image" >&2; exit 1
fi
cp "$WORK/build/Image" "$ROOT/images/linux-0.01-Image"
sha256sum "$ROOT/images/linux-0.01-Image"
printf '\nKernel image built. Test in QEMU first:\n  cd %q && make -f mvp.mk run\n' "$WORK"
printf '\nThis Image is NOT a v86 bzImage; a compatible BIOS/floppy/disk boot medium must be validated separately.\n'
