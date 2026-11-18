#!/usr/bin/env bash
# Rebuild the previously validated Linux 0.99.12 kernel with legacy ISA network probes disabled.
# Preserve the working 1993 QEMU boot image until the new one is built successfully.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/.work/linux-1993/linux-evocation"
FLOPPY="$ROOT/.work/linux-1993/linux-0.99.12-floppy.img"
[[ -s "$SRC/.config" && -s "$SRC/zImage" && -s "$FLOPPY" ]] || { echo "Missing existing 1993 build; run prepare-linux-1993.sh first" >&2; exit 1; }
command -v docker >/dev/null || { echo "Docker is required" >&2; exit 1; }
cp -p "$SRC/.config" "$SRC/.config.before-v86-netfix"
cp -p "$FLOPPY" "$FLOPPY.before-v86-netfix"
python3 - "$SRC/.config" <<'PY'
from pathlib import Path
import re,sys
p=Path(sys.argv[1])
s=p.read_text()
# Disable all ISA Ethernet autodetection and legacy serial/parallel networking.
keys=["CONFIG_ETHERCARDS","CONFIG_NE2000","CONFIG_WD80x3","CONFIG_EL2",
      "CONFIG_HPLAN","CONFIG_AT1500","CONFIG_DE600","CONFIG_PLIP","CONFIG_SLIP"]
for key in keys:
    pattern=r"(?m)^"+re.escape(key)+r"\s*=.*$"
    if re.search(pattern,s):
        s=re.sub(pattern,key+"=n",s)
    else:
        s+="\n"+key+"=n"
p.write_text(s)
print("Disabled legacy network drivers:",", ".join(keys))
PY
docker run --rm --platform linux/amd64 -v "$SRC:/src" -w /src ubuntu:20.04 bash -euc '
 export DEBIAN_FRONTEND=noninteractive
 apt-get update -qq
 apt-get install -y -qq --no-install-recommends build-essential bin86 bc libc6-dev-i386 gcc-multilib make binutils >/dev/null
 make clean
 make dep
 make -j2
 test -s zImage
'
# Build new boot floppy atomically; root device /dev/hda1 = major 3, minor 1.
TMP="$FLOPPY.new"
truncate -s 1474560 "$TMP"
dd if="$SRC/zImage" of="$TMP" conv=notrunc status=none
printf '\\x01\\x03' | dd of="$TMP" bs=1 seek=508 conv=notrunc status=none
mv "$TMP" "$FLOPPY"
echo "Rebuilt 1993 floppy: $FLOPPY"
echo "Previous working image: $FLOPPY.before-v86-netfix"
echo "Run bash scripts/package-real-kernel-site.sh, then test 1993 in the browser."
