#!/bin/sh
# Alpine 3.21 x86: Ubuntu 4.10-inspired Openbox desktop (not an authentic Ubuntu installation).
# Run as root inside the 2004 era guest. Safe to rerun.
set -eu
id demo >/dev/null 2>&1 || { echo "Missing demo user" >&2; exit 1; }
apk add openbox xterm tint2 xsetroot font-dejavu dbus jgmenu adwaita-icon-theme
HOME_DIR=/home/demo
mkdir -p "$HOME_DIR/.config/openbox" "$HOME_DIR/.config/tint2" "$HOME_DIR/.local/share/applications"
cat >"$HOME_DIR/.xinitrc" <<'EOF'
#!/bin/sh
exec openbox-session
EOF
cat >"$HOME_DIR/.config/openbox/autostart" <<'EOF'
#!/bin/sh
(sleep 1; xsetroot -solid '#6B4534') &
tint2 -c "$HOME/.config/tint2/top.tint2rc" &
tint2 -c "$HOME/.config/tint2/bottom.tint2rc" &
EOF
cat >"$HOME_DIR/.config/tint2/top.tint2rc" <<'EOF'
# Ubuntu 4.10-inspired upper panel
rounded = 0
border_width = 0
background_color = #6B4534 100
background_id = 1
panel_items = L
panel_position = top center horizontal
panel_size = 100% 32
panel_margin = 0 0
panel_padding = 8 0 6
panel_background_id = 1
launcher_padding = 6 4 6
launcher_icon_size = 24
launcher_item_app = /home/demo/.local/share/applications/era-applications.desktop
launcher_item_app = /home/demo/.local/share/applications/era-terminal.desktop
EOF
cat >"$HOME_DIR/.config/tint2/bottom.tint2rc" <<'EOF'
# Ubuntu 4.10-inspired lower panel
rounded = 0
border_width = 0
background_color = #6B4534 100
background_id = 1
panel_items = TSC
panel_position = bottom center horizontal
panel_size = 100% 28
panel_margin = 0 0
panel_padding = 6 0 6
panel_background_id = 1
taskbar_mode = single_desktop
taskbar_padding = 4 2 4
task_padding = 5 2 5
task_font = DejaVu Sans 9
task_font_color = #FFFFFF 100
task_active_font_color = #FFFFFF 100
time1_format = %H:%M
time1_font = DejaVu Sans 9
clock_font_color = #FFFFFF 100
EOF
cat >"$HOME_DIR/.local/share/applications/era-applications.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Applications
Comment=Open the applications menu
Exec=jgmenu_run
Icon=start-here
Terminal=false
Categories=System;
EOF
cat >"$HOME_DIR/.local/share/applications/era-terminal.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Terminal
Exec=xterm
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
EOF
chown -R demo:demo "$HOME_DIR/.config" "$HOME_DIR/.local"
chown demo:demo "$HOME_DIR/.xinitrc"
chmod +x "$HOME_DIR/.xinitrc" "$HOME_DIR/.config/openbox/autostart"
echo "2004 desktop updated. Restart the demo X session to apply both panels."
echo "This is an Alpine-based visual reconstruction, not Ubuntu 4.10 or GNOME 2."
