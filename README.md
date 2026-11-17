# Linux Time Machine

**The past is open source.** An original retro-futuristic interactive journey through Linux history, starting with the 1991 Linux 0.01 era.

**Live demo:** https://linux-time-machine.pages.dev/  
**Planned domain:** https://linuxtimemachine.org/

## What is available

- Original 2027-style time-travel interface: neon cyan, copper, sci-fi portal and an original generic futuristic vehicle illustration (all CSS; no movie assets)
- Interactive 1991 educational shell reconstruction
- Five selectable educational eras: 1991, 1993, 1998, 2004, and 2026\n- Era-specific simulated filesystems, historical context, commands, and clickable command suggestions\n- Original illustrative desktop concepts for 1998, 2004, and 2026 (not real historical desktops)
- Responsive layout, keyboard command history, reduced-motion support
- No backend or server-side computation required

### Important historical distinction

The terminal is a **simulation**, not a real Linux 0.01 boot. Its commands operate on a small in-memory representation of source tree concepts. The authentic 1991 kernel source can be found at https://www.kernel.org/pub/linux/kernel/Historic/.

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
