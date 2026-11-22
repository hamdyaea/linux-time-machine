# Search and sharing deployment checklist

Canonical hostname: **https://linuxtimemachine.org/**

## What this change adds

- Descriptive homepage title, meta description, canonical URL, Open Graph and Twitter cards, and schema.org WebSite/Person descriptions
- Self-referencing canonical URLs and sharing metadata on About and Developer pages
- A sitemap with the three canonical public pages, plus a robots.txt sitemap declaration
- A static `assets/linux-time-machine-social.png` share card (an **illustration**, not an actual screenshot of an emulated guest)
- Updated README/About with a clear distinction between historical x86 guest configurations and educational reconstructions

## Important: preserve production VMs

Linux VM disk images and the v86 browser emulator runtime are deliberately **not committed** to Git. The public production deployment uses a separately packaged directory. **Do not activate a plain Git-to-Pages production build or replace the existing production Pages bundle with this source tree.** Otherwise historical guests will lose their required assets.

When the production machine and established deployment method are available:

1. Fetch these changes into the locally prepared source checkout without overwriting the `images/`, `vendor/v86/` or `.work/` guest assets.
2. Build a complete Pages bundle using the existing tested packaging process. It now copies `robots.txt` and `sitemap.xml`, and copies `assets/*` (including the new social card).
3. Test guest boot and typed shell input for each enabled historical VM before deployment. Check the required assets (including split disks, when applicable), response content types, CSP, cross-origin headers and range requests for the 2004 remote disk.
4. Deploy the complete tested bundle using the site's existing direct-upload workflow. Avoid an automatic source-only Pages deployment.
5. Confirm the following pages return real content, not SPA fallback HTML: `/`, `/about`, `/developer`, `/robots.txt`, `/sitemap.xml`, `/assets/linux-time-machine-social.png`.
6. Verify canonical tags and social preview image size (1200×630) using the public hostname. Confirm the public VMs still start before promoting the site publicly.

## Redirect the pages.dev domain

A single `_redirects` file distributed to both Pages hostnames cannot safely implement an unconditional cross-host redirect: it can cause a loop on the custom hostname. Cloudflare recommends **Bulk Redirects** to route `linux-time-machine.pages.dev` to `linuxtimemachine.org`. Configure this in the Cloudflare dashboard using [the official guide](https://developers.cloudflare.com/pages/how-to/redirect-to-custom-domain/), preserving the request path when applicable. Do not guess that the redirect is already enabled.

Test:

```bash
curl -sSIL https://linux-time-machine.pages.dev/
curl -sSIL https://linuxtimemachine.org/
curl -sSIL https://linuxtimemachine.org/about
curl -sSIL https://linuxtimemachine.org/developer
curl -sSIL https://linuxtimemachine.org/sitemap.xml
curl -sSIL https://linuxtimemachine.org/robots.txt
curl -sSIL https://linuxtimemachine.org/assets/linux-time-machine-social.png
```

The preferred canonical for `/about.html` is `/about` and for `/developer.html` is `/developer`. Cloudflare Pages commonly redirects `.html` to clean extensionless URLs.

## Google Search Console

This repository does not give an authenticated API session for Google Search Console, so indexing status cannot be verified here. After deploying the complete site, submit `https://linuxtimemachine.org/sitemap.xml` in Search Console and inspect `/`, `/about` and `/developer` for indexing. Request indexing as needed; submitting does not guarantee inclusion in search results.

## Video marketing / accuracy

Capture real browser footage **only on the verified production deployment**, with visible actual guest output and typed commands, for a 30–60-second video. Explicitly label educational desktop reconstructions as reconstructions. Do not substitute a simulated command-line animation for proof of a historical kernel boot.

Suggested shot list: 0–6 s project title, 6–18 s Linux 0.01 genuine live boot, 18–30 s Linux 0.99.12/Slackware 1993 live boot, 30–40 s Red Hat 1998 or 2004 guest (where verified), 40–52 s interactive reconstructions and mobile terminal, 52–58 s URL/GitHub/author credit.
