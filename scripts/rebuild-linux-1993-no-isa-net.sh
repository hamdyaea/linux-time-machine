#!/usr/bin/env bash
# Rebuild the previously validated Linux 0.99.12 kernel with legacy ISA network probes disabled.
# Preserve the working 1993 QEMU boot image until the new one is built successfully.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/.work/linux-1993/linux-evocation"
FLOPPY="$ROOT/.work/linux-1993/linux-0.99.12-floppy.img"
[[ -s "$SRC/.config" && -s "$SRC/Makefile" && -s "$FLOPPY" ]] || { echo "Missing 1993 source configuration or boot floppy; check .work/linux-1993" >&2; exit 1; }
# zImage is intentionally NOT required: make clean removes it before recompilation.
command -v docker >/dev/null || { echo "Docker is required" >&2; exit 1; }
if [[ ! -w "$SRC/.config" || ! -w "$SRC" ]]; then
 echo "Fixing ownership of Docker-generated kernel build files..." >&2
 sudo chown -R "$(id -u):$(id -g)" "$SRC"
fi
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
# This 1993 tree uses generated autoconf.h and net/inet/CONFIG in addition to .config.
# Editing .config alone leaves the actual driver probes enabled.
python3 - "$SRC/include/linux/autoconf.h" "$SRC/net/inet/CONFIG" <<'PY'
from pathlib import Path
import re, sys
header, netmap = map(Path, sys.argv[1:])
keys = ["CONFIG_ETHERCARDS", "CONFIG_NE2000", "CONFIG_WD80x3", "CONFIG_EL2",
        "CONFIG_HPLAN", "CONFIG_AT1500", "CONFIG_DE600", "CONFIG_PLIP", "CONFIG_SLIP"]
s = header.read_text()
# Repair previous faulty run which inserted literal backslash-n sequences.
s = s.replace(r"\n#undef CONFIG_", "\n#undef CONFIG_")
s = re.sub(r"(?m)^\\n$", "", s)
for key in keys:
    s = re.sub(r"(?m)^[ \t]*#[ \t]*(?:define|undef)[ \t]+" + re.escape(key) + r"\b[^\n]*\n?", "", s)
s = s.rstrip("\n") + "\n" + "".join("#undef " + key + "\n" for key in keys)
header.write_text(s)
n = netmap.read_text()
n = re.sub(r"(?m)^[ \t]*CARDS[ \t]*:?=[ \t]*\$\(CARDS\)[ \t]+-D(?:WD80x3|NE2000|HPLAN|EL2|D_LINK|CONFIG_AT1500)\b[^\n]*$", lambda m: "# disabled for v86: " + m.group(0), n)
netmap.write_text(n)
assert r"\n#undef CONFIG_" not in header.read_text()
print("Repaired autoconf.h; disabled ISA network probes in net/inet/CONFIG")
PY
# Explicitly remove the legacy 8390/NE2000 device from the 1993 boot probe
# chain. The driver may still be linked, but cannot be auto-probed.
python3 - "$SRC/net/inet/Space.c" <<'PY'
from pathlib import Path
import re,sys
p=Path(sys.argv[1])
s=p.read_text()
pattern=r"(?m)^#if defined\(EI8390\) \|\| defined\(CONFIG_EL2\) \|\| defined\(CONFIG_NE2000\)"
if re.search(pattern,s):
    s=re.sub(pattern, "#if 0 /* v86: disable legacy 8390/NE2000 ISA autoprobe */", s, count=1)
elif "#if 0 /* v86: disable legacy 8390/NE2000 ISA autoprobe */" not in s:
    raise SystemExit("Cannot locate 8390 device block in Space.c; refusing unverified patch")
p.write_text(s)
print("Disabled 8390/NE2000 device initialization in Space.c")
PY
docker run --rm --platform linux/amd64 \
 -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
 -v "$SRC:/src" -w /src ubuntu:20.04 bash -euc '
 export DEBIAN_FRONTEND=noninteractive
 apt-get update -qq
 apt-get install -y -qq --no-install-recommends build-essential bin86 bc libc6-dev-i386 gcc-multilib make binutils util-linux >/dev/null
 # Drop root privileges for the build, preserving host file ownership.
 setpriv --reuid="$HOST_UID" --regid="$HOST_GID" --clear-groups bash -euc "
  make clean
  make dep
  make -j2
  test -s zImage
 "
'
# Build new boot floppy atomically; root device /dev/hda1 = major 3, minor 1.
TMP="$FLOPPY.new"
truncate -s 1474560 "$TMP"
dd if="$SRC/zImage" of="$TMP" conv=notrunc status=none
printf '\x01\x03' | dd of="$TMP" bs=1 seek=508 conv=notrunc status=none
mv "$TMP" "$FLOPPY"
echo "Rebuilt 1993 floppy: $FLOPPY"
echo "Previous working image: $FLOPPY.before-v86-netfix"
echo "Run bash scripts/package-real-kernel-site.sh, then test 1993 in the browser."
