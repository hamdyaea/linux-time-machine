#!/bin/sh
# Make LXTerminal autostart reliable without changing the working menu.
set -eu
H=/home/demo
AUTO="$H/.config/openbox/autostart"
id demo >/dev/null 2>&1 || exit 1
command -v lxterminal >/dev/null 2>&1 || { echo 'lxterminal not installed' >&2; exit 1; }
[ -f "$AUTO" ] || { echo "Missing $AUTO" >&2; exit 1; }
cp "$AUTO" "$AUTO.before-terminal-fix"
# Remove the previous delayed terminal launcher and earlier tagged block.
sed -i '/^# era2004-start-apps$/d; /^[[:space:]]*(sleep 3; lxterminal) &$/d; /^# era2004-terminal-start$/d; /^.*lxterminal --command=.*$/d' "$AUTO"
cat >> "$AUTO" <<'EOF'

# era2004-terminal-start
(
  sleep 4
  if ! pgrep -u demo -x lxterminal >/dev/null 2>&1; then
    lxterminal >/home/demo/.cache/era2004-lxterminal.log 2>&1
  fi
) &
EOF
mkdir -p "$H/.cache"
chown demo:demo "$AUTO" "$AUTO.before-terminal-fix" "$H/.cache"
chmod +x "$AUTO"
echo 'LXTerminal autostart updated. Reboot to test.'
echo 'If missing, inspect /home/demo/.cache/era2004-lxterminal.log'
