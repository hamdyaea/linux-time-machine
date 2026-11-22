# Linux Time Machine

**The past is open source.** Explore historical Linux kernels, retro desktops, and the evolution of the operating system in your browser.

**Official website:** https://linuxtimemachine.org/  
**Source code:** https://github.com/hamdyaea/linux-time-machine  
**Created and maintained by:** [Hamdy Abou El Anein](https://linuxtimemachine.org/developer)

## What can you explore?

Linux Time Machine has **two distinct types of experiences**:

1. **Historical x86 guest environments:** the site is configured to boot real historical Linux kernels and period systems through the [v86](https://github.com/copy/v86) browser emulator. These require separately packaged BIOS, WASM and disk-image assets. The Linux 0.01 and Linux 0.99.12 kernels use compatibility patches to run with newer toolchains/emulation.
2. **Interactive historical reconstructions:** later eras use educational terminal and desktop recreations. They are *not* original running operating systems and should not be confused with the emulated x86 guests.

| Era | Experience | Technical distinction |
| --- | --- | --- |
| **1991 — Linux 0.01** | Browser x86 guest configuration | Compatibility-patched Linux 0.01-derived kernel with a period-style disk environment |
| **1993 — Slackware 1.01** | Browser x86 guest configuration | Linux 0.99.12 kernel and period Slackware disk |
| **1998 — Red Hat 5.2** | Browser x86 guest configuration | Historical Red Hat x86 disk image |
| **2004 — Ubuntu era** | Browser x86 guest configuration | Ubuntu-era recreation; not represented as an unchanged original Ubuntu 4.10 installation |
| **2010 → today** | Interactive reconstructions | Era-themed Linux history, terminal commands, desktop presentations and context |

The landing page integrates keyboard-driven terminal exploration, suggestions for commands, a timeline, historical explanations and an x86 emulator display for selected early eras. On narrow screens, the site can present an interactive command experience where an x86 guest is not available.

**Historical accuracy and boot status.** The published JavaScript defines the browser guests, but *this repository does not include the large guest disks or the v86 binaries*. Those are generated or staged locally during packaging and deployed separately. A source-tree inspection alone therefore cannot establish whether a particular public VM currently boots. Verify actual browser operation on the production URL before describing a specific VM as fully tested. A JavaScript-rendered prompt or printed `uname` version is not proof of a running kernel.

## Developer

**Hamdy Abou El Anein** — creator, lead developer and maintainer. Senior Linux Systems Engineer, open-source developer and technical educator based in Switzerland.

- Developer profile: https://linuxtimemachine.org/developer
- Project background: https://linuxtimemachine.org/about
- GitHub: https://github.com/hamdyaea
- Daylight Linux: https://daylightlinux.ch
- Email: info@daylightlinux.ch

Contributions, historical research, reproducible boot reports, testing and suggestions are welcome through GitHub issues and pull requests.

## Technology

HTML5, CSS3, vanilla JavaScript, [v86](https://github.com/copy/v86) for x86 guest emulation, and Cloudflare Pages for static hosting. Historical disk media may be served from bundled Pages assets or an externally configured disk endpoint.

## Run the static front end locally

```bash
git clone https://github.com/hamdyaea/linux-time-machine.git
cd linux-time-machine
python3 -m http.server 8000
```

Open http://localhost:8000. **This static checkout does not include the guest disk images or v86 runtime**, so real VM boot requires the separate preparation steps documented in [the boot engineering guide](docs/REAL_KERNEL_BOOT.md).

## Packaging and deployment

The production guest images are not stored in Git; they are deliberately excluded due to their size and third-party components. `scripts/package-real-kernel-site.sh` assembles HTML, JavaScript, emulator assets and prepared disk images into a static deployable directory.

**Do not replace a working production deployment with a plain Git checkout or a default Git-based Cloudflare Pages build.** Such a deployment can omit existing VM assets and cause historical machines to stop booting. First rebuild the complete bundle, preserve the current deployed disk assets, validate 1991/1993/1998/2004 browser boots where applicable, and publish the verified bundle using the established Cloudflare Pages direct-upload workflow.

SEO files (`robots.txt`, `sitemap.xml` and the social preview) must also be included in that packaged deployment. See [SEO deployment and verification](docs/SEO_DEPLOYMENT.md).

## References

- [Historic Linux kernel archives](https://www.kernel.org/pub/linux/kernel/Historic/)
- [Linux source history](https://kernel.googlesource.com/pub/scm/linux/kernel/git/nico/archive/)
- [v86 browser x86 emulator](https://github.com/copy/v86)
- [Linux 0.01 boot engineering notes](docs/REAL_KERNEL_BOOT.md)

## License and attribution

Copyright © 2026 **Hamdy Abou El Anein** and contributors. Released under the [MIT License](LICENSE).

Historical third-party kernels, distributions, emulator software, disk images and trademarks retain their respective licenses and attribution requirements. Linux is a trademark of Linus Torvalds. Linux Time Machine is an independent open-source project.
