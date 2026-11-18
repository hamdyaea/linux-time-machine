#!/bin/sh
# Ubuntu 4.10-inspired Alpine/Openbox reconstruction. Run as root INSIDE era 2004 guest.
set -eu
id demo >/dev/null 2>&1 || { echo "Missing demo user" >&2; exit 1; }
apk add openbox xterm tint2 xsetroot font-dejavu dbus
mkdir -p /home/demo/.config/openbox /home/demo/.config/tint2
cat >/home/demo/.xinitrc <<'EOF'
#!/bin/sh
exec openbox-session
EOF
cat >/home/demo/.config/openbox/autostart <<'EOF'
#!/bin/sh
xsetroot -solid '#6B4534' &
tint2 -c "$HOME/.config/tint2/bottom.tint2rc" &
tint2 -c "$HOME/.config/tint2/top.tint2rc" &
EOF
cat >/home/demo/.config/tint2/top.tint2rc <<'EOF'
panel_items = L
panel_position = top center horizontal
panel_size = 100% 30
panel_margin = 0 0
panel_padding = 8 0 8
panel_background_id = 1
background_color = #5E3525 100
border_width = 0
rounded = 0
taskbar_mode = single_desktop
launcher_padding = 5 5 5
launcher_icon_size = 20
launcher_item_app = /home/demo/.local/share/applications/era-applications.desktop
launcher_item_app = /home/demo/.local/share/applications/era-terminal.desktop
EOF
cat >/home/demo/.config/tint2/bottom.tint2rc <<'EOF'
panel_items = TSC
panel_position = bottom center horizontal
panel_size = 100% 28
panel_margin = 0 0
panel_padding = 5 0 5
panel_background_id = 1
background_color = #6C493A 100
border_width = 0
rounded = 0
taskbar_mode = single_desktop
taskbar_padding = 2 2 2
task_padding = 4 2 4
task_font = DejaVu Sans 9
task_font_color = #FFFFFF 100
task_active_font_color = #FFFFFF 100
time1_format = %H:%M
time1_font = DejaVu Sans 9
clock_font_color = #FFFFFF 100
EOF
mkdir -p /home/demo/.local/share/applications
cat >/home/demo/.local/share/applications/era-applications.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Applications
Exec=sh -c 'xterm -title Applications -e sh -c "printf \"Applications\\n\\n1. Terminal: xterm\\n2. Openbox menu: right-click desktop\\n\\nPress Enter to close\"; read x"'
Icon=applications-system
Terminal=false
EOF
cat >/home/demo/.local/share/applications/era-terminal.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Terminal
Exec=xterm
Icon=utilities-terminal
Terminal=false
EOF
chown -R demo:demo /home/demo/.config /home/demo/.local
chown demo:demo /home/demo/.xinitrc
chmod +x /home/demo/.xinitrc /home/demo/.config/openbox/autostart
echo "2004 desktop configuration installed. Restart demo X session (startx)."
echo "NOTE: This is a first two-panel prototype, not an authentic GNOME 2 desktop."
