#!/bin/sh
# Limit the Alpine 2004 reconstruction to Files and Terminal.
# Run as root INSIDE the 2004 guest; rerunnable.
set -eu
id demo >/dev/null 2>&1 || { echo 'Missing demo user' >&2; exit 1; }
command -v pcmanfm >/dev/null 2>&1 || { echo 'Missing pcmanfm' >&2; exit 1; }
command -v lxterminal >/dev/null 2>&1 || { echo 'Missing lxterminal' >&2; exit 1; }
command -v jgmenu_run >/dev/null 2>&1 || { echo 'Missing jgmenu_run' >&2; exit 1; }
H=/home/demo
mkdir -p "$H/.config/jgmenu" "$H/.config/openbox" "$H/.local/share/applications"
# A static two-entry menu avoids exposing installed support utilities.
cat >"$H/.config/jgmenu/era-menu.csv" <<'EOF'
Files,pcmanfm,system-file-manager
Terminal,lxterminal,utilities-terminal
EOF
# jgmenu executes csv_cmd to populate the menu.
if [ -f "$H/.config/jgmenu/jgmenurc" ]; then
  sed -i '/^csv_cmd[[:space:]]*=/d' "$H/.config/jgmenu/jgmenurc"
fi
printf '%s\n' 'csv_cmd = cat /home/demo/.config/jgmenu/era-menu.csv' >>"$H/.config/jgmenu/jgmenurc"
# Keep existing panel and background setup; append startup once.
AUTO="$H/.config/openbox/autostart"
touch "$AUTO"
if ! grep -q '^# era2004-start-apps$' "$AUTO"; then
  cat >>"$AUTO" <<'EOF'

# era2004-start-apps
(sleep 2; pcmanfm --no-desktop) &
(sleep 3; lxterminal) &
EOF
fi
# Remove extra era shortcuts from the XDG menu. Do not uninstall applications.
for entry in "$H/.local/share/applications/era-editor.desktop" "$H/.local/share/applications/era-files.desktop" "$H/.local/share/applications/era-terminal.desktop"; do
  if [ -f "$entry" ]; then
    case "$entry" in
      *era-files.desktop) name=Files; cmd=pcmanfm; ico=system-file-manager;;
      *era-terminal.desktop) name=Terminal; cmd=lxterminal; ico=utilities-terminal;;
      *) rm -f "$entry"; continue;;
    esac
    cat >"$entry" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Exec=$cmd
Icon=$ico
NoDisplay=true
EOF
  fi
done
chown -R demo:demo "$H/.config/jgmenu" "$H/.config/openbox" "$H/.local/share/applications"
chmod +x "$AUTO"
echo 'Configured two-entry menu and automatic Files + Terminal launch.'
echo 'Reboot to test.'
