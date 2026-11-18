#!/bin/sh
# Repair the 2004 top-panel Applications launcher without touching autostart.
set -eu
id demo >/dev/null 2>&1 || exit 1
command -v jgmenu_run >/dev/null 2>&1 || { echo 'jgmenu_run missing' >&2; exit 1; }
H=/home/demo
mkdir -p "$H/.local/share/applications" "$H/.local/bin" "$H/.config/tint2"
cat > "$H/.local/bin/era2004-menu" <<'EOF'
#!/bin/sh
exec /usr/bin/jgmenu_run
EOF
# Resolve actual jgmenu path, if different.
JGMENU=$(command -v jgmenu_run)
sed -i "s|/usr/bin/jgmenu_run|$JGMENU|" "$H/.local/bin/era2004-menu"
chmod 755 "$H/.local/bin/era2004-menu"
cat > "$H/.local/share/applications/era-applications.desktop" <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Applications
Comment=Open graphical applications menu
Exec=/home/demo/.local/bin/era2004-menu
Icon=start-here
Terminal=false
StartupNotify=false
NoDisplay=true
EOF
# Ensure the top launcher points only to the graphical menu.
P="$H/.config/tint2/top.tint2rc"
if [ -f "$P" ]; then
  sed -i '/^launcher_item_app[[:space:]]*=/d' "$P"
  printf '%s\n' 'launcher_item_app = /home/demo/.local/share/applications/era-applications.desktop' >> "$P"
fi
chown -R demo:demo "$H/.local/bin" "$H/.local/share/applications" "$H/.config/tint2"
echo 'Graphical Applications launcher repaired; reboot to reload tint2.'
