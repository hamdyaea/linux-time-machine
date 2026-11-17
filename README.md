# Linux Time Machine

**The past is open source.** An original retro-futuristic interactive journey through Linux history, starting with the 1991 Linux 0.01 era.

**Live demo:** https://linux-time-machine.pages.dev/  
**Planned domain:** https://linuxtimemachine.org/

## What is available

- Original 2027-style time-travel interface: neon cyan, copper, sci-fi portal and an original generic futuristic vehicle illustration (all CSS; no movie assets)
- Interactive 1991 educational shell reconstruction
- Five selectable educational eras: 1991, 1993, 1998, 2004, and 2026
- Era-specific simulated filesystems, historical context, commands, and clickable command suggestions
- Original illustrative desktop concepts for 1998, 2004, and 2026 (not real historical desktops)
- Responsive layout, keyboard command history, reduced-motion support
- No backend or server-side computation required

## Historical accuracy

Linux Time Machine recreates the look and workflows of selected Linux eras in the browser. The current terminal is implemented in JavaScript and its files are representative, not an original operating-system image. We intentionally keep implementation notes here rather than interrupting the experience with repeated notices. Exact historical source code is available at https://www.kernel.org/pub/linux/kernel/Historic/. A future v86 integration may add real guest execution.

## Cloudflare Pages deployment

Connect the repository and select:

- Framework preset: **None**
- Build command: **leave blank**
- Build output directory: **/** (repository root)
- Production branch: **main**

Cloudflare deploys automatically on pushes to main. No Node.js or package installation is required.

## Local development

Run `python3 -m http.server 8000` and visit http://localhost:8000.

## Technology

HTML, CSS, vanilla JavaScript. Google Fonts provides optional typography with system-font fallback. Cloudflare Pages `_headers` configures security headers.

## Roadmap

1. Improve historical references and verify every sample against original releases.
2. Expand desktop concepts into interactive windows, menus, and applications.
3. Evaluate an optional real Linux browser VM using v86 and a small compatible guest (Tiny Core is a candidate, not integrated yet).
4. Expand the timeline and interactive experiences.

## License and intellectual property

**MIT License** for original project code, see [LICENSE](LICENSE). The license does not grant rights to third-party trademarks, historical screenshots, Linux distributions, or assets added later under other licenses.

The vehicle, portal, dashboard, and time-travel visual identity are original generic science-fiction artwork implemented with CSS, and do not reproduce a specific film vehicle, title treatment, logo, or other protected movie elements.

Linux is a trademark of Linus Torvalds. This is an independent educational project, not affiliated with Linus Torvalds, the Linux Foundation, or any motion picture franchise.

Created as part of the [Daylight Linux](https://daylightlinux.ch) ecosystem.

## Real historical kernel boot: feasibility work

The next milestone is a **real guest kernel**, not a JavaScript shell with a changed version string.

- **1991 / Linux 0.01:** original source: https://kernel.googlesource.com/pub/scm/linux/kernel/git/nico/archive/+/v0.01 . The release depends on period-specific i386 hardware assumptions and an early MINIX-compatible bootstrap/userspace. Build a reproducible kernel + filesystem + boot image first, validate it under a known-working PC emulator, then test browser-based x86 emulation. A QEMU-compatible disk image does **not** automatically boot in v86. Avoid claiming native Linux 0.01 boot until an actual browser test passes.
- **Emulator candidate:** https://github.com/copy/v86 (x86-to-WebAssembly browser PC emulator). Its documented compatibility is useful for 32-bit Linux, but Linux 0.01 is not documented as supported.
- **Reference implementation for research:** https://github.com/FermiHart/linux-0.01-still-runs includes an original-derived kernel with modern compatibility adaptations; its KVM-specific boot method is not directly usable in browsers.
- **Later eras:** source and validate redistributable period-correct 32-bit disk images, include license/source provenance, and host immutable image assets on Cloudflare-compatible storage. Never substitute Tiny Core for a 1991 kernel and label it Linux 0.01.

Current deployment: interactive historical terminal UI. **No actual guest kernel image or v86 runtime has been integrated or verified yet.** This distinction belongs in project documentation, not inside the terminal session.
