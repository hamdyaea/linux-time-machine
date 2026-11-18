#!/bin/sh
# Local-only automatic login and X startup for Alpine Linux 3.21 BusyBox init.
# Run as root inside the 2004 era guest. Serial ttyS0 and tty2-tty6 are untouched.
set -eu
id demo >/dev/null 2>&1 || { echo 'Missing demo user' >&2; exit 1; }
command -v startx >/dev/null 2>&1 || { echo 'Missing startx (xinit)' >&2; exit 1; }
command -v openbox-session >/dev/null 2>&1 || { echo 'Missing openbox-session' >&2; exit 1; }
[ -x /sbin/getty ] || { echo 'Missing /sbin/getty' >&2; exit 1; }
[ -x /bin/login ] || [ -x /usr/bin/login ] || { echo 'Missing login binary' >&2; exit 1; }
# BusyBox getty -n skips prompting; -l runs a login helper.
# /bin/login -f demo requires root and does not request a password.
LOGIN_BIN=/bin/login
[ -x "$LOGIN_BIN" ] || LOGIN_BIN=/usr/bin/login
[ -e /etc/inittab.before-2004-autologin ] || cp /etc/inittab /etc/inittab.before-2004-autologin
mkdir -p /usr/local/sbin
cat >/usr/local/sbin/era2004-autologin <<EOF
#!/bin/sh
exec "$LOGIN_BIN" -f demo
EOF
chmod 755 /usr/local/sbin/era2004-autologin
# Replace exactly the existing tty1 getty entry; do not add duplicate lines.
grep -q '^tty1::respawn:' /etc/inittab || { echo 'tty1 entry not found; aborting' >&2; exit 1; }
sed -i 's|^tty1::respawn:.*|tty1::respawn:/sbin/getty -n -l /usr/local/sbin/era2004-autologin 38400 tty1|' /etc/inittab
# Preserve an existing profile if one exists.
[ -e /home/demo/.profile.before-2004-autologin ] || {
  if [ -e /home/demo/.profile ]; then cp /home/demo/.profile /home/demo/.profile.before-2004-autologin; fi
}
cat >/home/demo/.profile <<'EOF'
# Only launch the desktop on the physical VGA console, not serial or SSH.
if [ -z "${DISPLAY:-}" ] && [ "$(tty 2>/dev/null)" = /dev/tty1 ]; then
  exec startx
fi
EOF
chown demo:demo /home/demo/.profile
chmod 644 /home/demo/.profile
echo 'Configured BusyBox tty1 autologin; reboot to test.'
echo 'Rollback from root serial console:'
echo '  cp /etc/inittab.before-2004-autologin /etc/inittab'
echo '  rm -f /home/demo/.profile'
echo '  reboot'
