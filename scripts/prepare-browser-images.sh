#!/usr/bin/env bash
# Extract the two disk images used by the working Linux 0.01 QEMU setup.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${LINUX01_WORKDIR:-$ROOT/.work/linux-0.01}"
mkdir -p "$ROOT/images"
if ! command -v docker >/dev/null; then echo "Docker required" >&2; exit 1; fi
if ! docker info >/dev/null 2>&1; then echo "Docker daemon unavailable" >&2; exit 1; fi
if [[ ! -s "$WORK/build/Image" ]]; then
 echo "Missing kernel: $WORK/build/Image. Run bash scripts/build-linux-0.01.sh first." >&2
 exit 1
fi
cp "$WORK/build/Image" "$ROOT/images/linux-0.01-floppy.img"
# Use exactly the runtime image from the upstream QEMU recipe.
docker buildx build --platform linux/amd64 --target runtime --load -t linux-0.01-mvp "$WORK"
cid="$(docker create --platform linux/amd64 linux-0.01-mvp)"
trap 'docker rm -f "$cid" >/dev/null 2>&1 || true' EXIT
docker cp "$cid:/run/hd_oldlinux.img" "$ROOT/images/linux-0.01-hda.img"
test -s "$ROOT/images/linux-0.01-hda.img"
echo "Images prepared:"
ls -lh "$ROOT/images/linux-0.01-floppy.img" "$ROOT/images/linux-0.01-hda.img"
sha256sum "$ROOT/images/linux-0.01-floppy.img" "$ROOT/images/linux-0.01-hda.img"
echo "Next: stage these files together with v86 runtime files under the Cloudflare static output."
