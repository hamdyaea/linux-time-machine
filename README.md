# Linux Time Machine

**The past is open source.** Travel through the evolution of Linux, from the first kernel release in 1991 to today's graphical desktops and beyond.

**Website:** https://linux-time-machine.pages.dev/  
**Project domain:** https://linuxtimemachine.org/  
**Source:** https://github.com/hamdyaea/linux-time-machine

## Explore Linux history

- **1991 — Linux 0.01:** the first kernel sources and early i386 architecture
- **1993 — Early distributions:** Slackware, Debian, and the command line
- **1998 — KDE 1.0:** the graphical desktop revolution
- **2004 — Ubuntu 4.10:** Linux reaches a wider desktop audience
- **2010 — Cloud and mobile:** Android, virtualization and emerging cloud platforms
- **2015 — Container revolution:** Docker, Kubernetes and application portability
- **2020 — Cloud native:** eBPF, observability and infrastructure at scale
- **2024 — Linux 6.x:** Modern kernel development and Rust support
- **Today — Modern Linux:** open-source infrastructure and desktop environments

The site features an interactive terminal with period-inspired prompts, command history, tab completion, a black-and-green CRT display, a time-travel portal, and commands selected for each era.

## Developer

**Hamdy Abou El Anein** — creator, lead developer, and maintainer.

Senior Linux System Engineer · Open-source developer · Cybersecurity specialist.

- **GitHub:** https://github.com/hamdyaea
- **Daylight Linux:** https://daylightlinux.ch\n- **Email:** info@daylightlinux.ch\n- **Developer page:** https://linux-time-machine.pages.dev/developer.html\n- **About page:** https://linux-time-machine.pages.dev/about.html
- **Linux Time Machine:** https://linux-time-machine.pages.dev/

Contributions, historical research, testing, and suggestions are welcome through GitHub issues and pull requests.

## Technology

HTML5, CSS3, and vanilla JavaScript. Static hosting on Cloudflare Pages. Accessible keyboard navigation and reduced-motion support.

## Run locally

```bash
git clone https://github.com/hamdyaea/linux-time-machine.git
cd linux-time-machine
python3 -m http.server 8000
```

Open http://localhost:8000.

## Deploy to Cloudflare Pages

Connect the GitHub repository to Cloudflare Pages, select the **main** branch, choose **None** as the framework preset, leave the build command blank, and set the output directory to the repository root (`/`).

## Historical sources and future development

- Linux historical source archives: https://www.kernel.org/pub/linux/kernel/Historic/
- Linux kernel source history: https://kernel.googlesource.com/pub/scm/linux/kernel/git/nico/archive/
- v86 x86 browser emulator: https://github.com/copy/v86

The [Linux 0.01 boot engineering track](docs/REAL_KERNEL_BOOT.md) includes a reproducible kernel build workflow and the steps for testing an x86 browser boot. Upcoming work also covers richer desktop interactions, expanded command support, and additional milestones.

## License

Copyright © 2026 **Hamdy Abou El Anein** and contributors.

Released under the [MIT License](LICENSE). Historical third-party software, distribution images, and trademarks remain subject to their respective rights and licenses.

Linux is a trademark of Linus Torvalds. Linux Time Machine is an independent open-source project.
