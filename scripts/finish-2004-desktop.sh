#!/bin/sh
# Stage 2: make the Alpine 2004 reconstruction usable.
# Run as root inside alpine-era-2004.qcow2; does not touch other era disks.
set -eu
id demo >/dev/null
apk add jgmenu xterm mousepad pcmanfm lxterminal adwaita-icon-theme hicolor-icon-theme font-dejavu xsetroot tint2 openbox
HOME_DIR=/home/demo
mkdir -p "$HOME_DIR/.config/jgmenu" "$HOME_DIR/.config/openbox" "$HOME_DIR/.local/share/applications"
# Put the applications menu near the upper-left, rather than screen center.
cat > "$HOME_DIR/.config/jgmenu/jgmenurc" <<'EOF'
csv_cmd = apps
tint2_look = 0
position_mode = fixed
menu_margin_x = 8
menu_margin_y = 34
menu_width = 240
item_height = 28
font = DejaVu Sans 10
color_menu_bg = #F3EDE5 100
color_norm_fg = #2C2019 100
color_sel_bg = #C76B33 100
color_sel_fg = #FFFFFF 100
icon_size = 20
EOF
# Add real applications with standard desktop entries.
cat > "$HOME_DIR/.local/share/applications/era-files.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Files
Exec=pcmanfm
Icon=system-file-manager
Categories=System;FileManager;
EOF
cat > "$HOME_DIR/.local/share/applications/era-editor.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Text Editor
Exec=mousepad
Icon=accessories-text-editor
Categories=Utility;TextEditor;
EOF
cat > "$HOME_DIR/.local/share/applications/era-terminal.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Terminal
Exec=lxterminal
Icon=utilities-terminal
Categories=System;TerminalEmulator;
EOF
# Use a guaranteed existing icon if the theme icon is not resolved by tint2.
ICON=/usr/share/icons/Adwaita/16x16/categories/applications-system-symbolic.symbolic.png
if [ -f "$ICON" ]; then
  sed -i "s|^Icon=.*|Icon=$ICON|" "$HOME_DIR/.local/share/applications/era-applications.desktop"
fi
chown -R demo:demo "$HOME_DIR/.config" "$HOME_DIR/.local"
echo "2004 desktop applications installed."
echo "Restart the demo graphical session to reload the menu and launcher."
echo "Test with: jgmenu_run; pcmanfm; mousepad; lxterminal"
