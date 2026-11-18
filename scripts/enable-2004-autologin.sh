#!/bin/sh
# Configure automatic local graphical login for the Alpine 2004 reconstruction.
# Run as root INSIDE the 2004 guest. No network/SSH autologin is configured.
set -eu
id demo >/dev/null 2>&1 || { echo "Missing user demo" >&2; exit 1; }
command -v startx >/dev/null 2>&1 || { echo "Install xinit first" >&2; exit 1; }
command -v openbox-session >/dev/null 2>&1 || { echo "Install openbox first" >&2; exit 1; }
apk add util-linux-login
# BusyBox init uses /etc/inittab. Replace tty1 getty with local autologin.
cp -n /etc/inittab /etc/inittab.before-2004-autologin
if grep -q '^tty1::respawn:' /etc/inittab; then
  sed -i 's|^tty1::respawn:.*|tty1::respawn:/sbin/agetty --autologin demo --noclear tty1 linux|' /etc/inittab
else
  echo 'tty1::respawn:/sbin/agetty --autologin demo --noclear tty1 linux' >> /etc/inittab
fi
# Start X only for the local tty1 login, never for SSH or serial console.
cat > /home/demo/.profile <<'EOF'
# Auto-start X only on the local VGA console.
if [ "${XDG_VTNR:-}" = "1" ] && [ -z "${DISPLAY:-}" ]; then
  exec startx
fi
EOF
# BusyBox agetty may not set XDG_VTNR; tty provides a portable fallback.
cat > /home/demo/.profile <<'EOF'
# Auto-start X only on the local VGA console.
if [ -z "${DISPLAY:-}" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
  exec startx
fi
EOF
chown demo:demo /home/demo/.profile
chmod 644 /home/demo/.profile
echo "Configured local tty1 autologin. Reboot to test."
echo "Rollback: cp /etc/inittab.before-2004-autologin /etc/inittab; rm /home/demo/.profile; reboot"
