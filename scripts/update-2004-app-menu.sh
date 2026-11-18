#!/bin/sh
# Maintain a minimal, accurate graphical menu for the 2004 Alpine reconstruction.
# Run as root inside the 2004 guest. Safe to rerun.
set -eu
H=/home/demo
id demo >/dev/null 2>&1 || { echo 'Missing demo user' >&2; exit 1; }
command -v jgmenu_run >/dev/null 2>&1 || { echo 'Missing jgmenu_run' >&2; exit 1; }
mkdir -p "$H/.config/jgmenu" "$H/.local/bin"
# Generate only entries for applications that are actually executable.
cat > "$H/.local/bin/era2004-menu-entries" <<'EOF'
#!/bin/sh
command -v pcmanfm >/dev/null 2>&1 && printf '%s\n' 'Files,pcmanfm,system-file-manager'
command -v lxterminal >/dev/null 2>&1 && printf '%s\n' 'Terminal,lxterminal,utilities-terminal'
command -v mousepad >/dev/null 2>&1 && printf '%s\n' 'Text Editor,mousepad,accessories-text-editor'
EOF
chmod 755 "$H/.local/bin/era2004-menu-entries"
CFG="$H/.config/jgmenu/jgmenurc"
touch "$CFG"
# Replace old csv_cmd, retaining the existing color and geometry settings.
sed -i '/^[[:space:]]*csv_cmd[[:space:]]*=/d' "$CFG"
printf '%s\n' 'csv_cmd = /home/demo/.local/bin/era2004-menu-entries' >> "$CFG"
# Retain compatibility with the existing static menu file for troubleshooting.
"$H/.local/bin/era2004-menu-entries" > "$H/.config/jgmenu/era-menu.csv"
chown -R demo:demo "$H/.config/jgmenu" "$H/.local/bin"
echo 'Menu entries actually available:'
cat "$H/.config/jgmenu/era-menu.csv"
echo 'Menu configuration updated. Reopen the menu (or reboot).'
