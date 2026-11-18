#!/bin/sh
# Fix menu anchoring and safely clean disposable files in Alpine 2004.
# Run as root in the 2004 guest. No package removal.
set -eu
H=/home/demo
CFG="$H/.config/jgmenu/jgmenurc"
[ -f "$CFG" ] || { echo "Missing $CFG" >&2; exit 1; }
echo '=== Disk usage BEFORE ==='
df -h /
du -sh /var/cache/apk /var/log /tmp /root/.cache "$H/.cache" 2>/dev/null || true
cp "$CFG" "$CFG.before-menu-position"
# jgmenu uses menu_halign/menu_valign, not position_mode, for fixed alignment.
sed -i '/^position_mode[[:space:]]*=/d; /^menu_halign[[:space:]]*=/d; /^menu_valign[[:space:]]*=/d; /^menu_margin_x[[:space:]]*=/d; /^menu_margin_y[[:space:]]*=/d' "$CFG"
cat >> "$CFG" <<'EOF'
menu_halign = left
menu_valign = top
menu_margin_x = 8
menu_margin_y = 34
EOF
chown demo:demo "$CFG" "$CFG.before-menu-position"
# Clear only disposable caches. Keep apk database and installed packages.
if command -v apk >/dev/null 2>&1; then apk cache clean 2>/dev/null || true; fi
rm -rf /var/cache/apk/* /root/.cache/*
if [ -d "$H/.cache" ]; then
  find "$H/.cache" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
fi
# Remove rotated/compressed logs only, never current logs.
find /var/log -type f \( -name '*.gz' -o -name '*.old' -o -name '*.1' \) -delete 2>/dev/null || true
echo '=== Disk usage AFTER ==='
df -h /
echo '=== Largest installed packages (informational only) ==='
apk info -s 2>/dev/null | tail -n 35 || true
echo '=== Top-level disk use ==='
du -x -h -d 1 /usr /var /home 2>/dev/null | sort -h | tail -n 20 || true
echo 'Menu anchored top-left. Reboot to apply; no packages were removed.'
