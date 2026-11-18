#!/bin/sh
# Replace the Openbox native applications menu with three installed apps.
# Also retain the separate jgmenu panel launcher.
set -eu
H=/home/demo
id demo >/dev/null 2>&1 || { echo 'Missing demo user' >&2; exit 1; }
mkdir -p "$H/.config/openbox"
# Openbox uses menu.xml for the desktop right-click menu; a stale default menu
# may list apps that were never installed. Provide a fully explicit menu.
MENU="$H/.config/openbox/menu.xml"
[ ! -f "$MENU" ] || cp "$MENU" "$MENU.before-era2004"
cat > "$MENU" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Applications">
    <item label="Files"><action name="Execute"><command>pcmanfm</command></action></item>
    <item label="Terminal"><action name="Execute"><command>lxterminal</command></action></item>
    <item label="Text Editor"><action name="Execute"><command>mousepad</command></action></item>
  </menu>
</openbox_menu>
EOF
# If rc.xml exists, ensure the root menu refers to the local menu definition.
# Standard Openbox searches ~/.config/openbox/menu.xml automatically.
chown demo:demo "$MENU"
if [ -f "$MENU.before-era2004" ]; then chown demo:demo "$MENU.before-era2004"; fi
echo 'Openbox native menu replaced with Files, Terminal, Text Editor.'
echo 'To apply without reboot: su - demo -c "DISPLAY=:0 XAUTHORITY=/home/demo/.Xauthority openbox --reconfigure"'
