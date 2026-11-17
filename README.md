# Linux Time Machine

Travel through Linux history, from 1991 to today, in your browser.

## Version 0.1 — 1991

The first experience is an **educational reconstruction** inspired by the Linux 0.01 era. It does **not** boot Linux 0.01, execute Linux binaries, or reproduce an authentic 1991 filesystem. Its shell commands operate on a small in-memory educational file tree.

### Features

- Responsive timeline and terminal UI
- Simulated commands: `help`, `ls`, `pwd`, `cd`, `cat`, `echo`, `clear`, `date`, `uname`, `whoami`, `history`, `about`, `source`
- Command history using arrow keys
- No backend, tracking, or external JavaScript dependencies
- Static deployment to Cloudflare Pages

## Cloudflare Pages

Connect this GitHub repository to Cloudflare Pages:

- Framework preset: **None**
- Build command: **leave blank**
- Build output directory: **/** (repository root)
- Production branch: **main**

No npm installation or build step is required. The site is plain HTML, CSS, and JavaScript.

## Local development

Serve the directory with any static HTTP server, for example `python3 -m http.server 8000`. Open http://localhost:8000.

## Roadmap

- Source-accurate exploration of the 1991 Linux kernel
- Historic desktop reproductions
- Optional real Linux guest using a browser emulator such as v86 (Tiny Core Linux is under evaluation)
- Additional eras from 1991 to modern Linux

## Historical source

https://www.kernel.org/pub/linux/kernel/Historic/

## Project

An independent open-source educational project associated with [Daylight Linux](https://daylightlinux.ch). Not affiliated with Linus Torvalds or the Linux Foundation.

## License

Source code license to be selected after checking rights for all included assets. No third-party historic desktop graphics are bundled.
