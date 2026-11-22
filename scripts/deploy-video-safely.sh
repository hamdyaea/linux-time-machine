#!/usr/bin/env bash
# Add the official Linux Time Machine video to a COPY of the existing Cloudflare
# Pages deployment bundle. Never rebuild or remove any historical VM assets.
#
# Usage from the checked-out repository root:
#   bash /tmp/ltm-deploy-video-safely.sh
#   DEPLOY=1 PAGES_PROJECT=linux-time-machine PAGES_BRANCH=main bash /tmp/ltm-deploy-video-safely.sh
#
# DEPLOY defaults to 0: check and stage only, without Cloudflare API calls.
set -Eeuo pipefail

ROOT="${LTM_ROOT:-$PWD}"
SOURCE="${LTM_PAGES_DIST:-$ROOT/.work/pages-dist}"
DEPLOY="${DEPLOY:-0}"
PAGES_PROJECT="${PAGES_PROJECT:-linux-time-machine}"
PAGES_BRANCH="${PAGES_BRANCH:-main}"

if [[ ! -d "$SOURCE" ]]; then
  echo "REFUSING: Complete existing Cloudflare bundle missing: $SOURCE" >&2
  echo "Find the previously deployed, complete pages-dist folder first." >&2
  exit 1
fi
for file in \
  index.html about.html style.css _headers vm.js vm.html app.js eras.js SHA256SUMS \
  vendor/v86/libv86.js vendor/v86/v86.wasm vendor/v86/seabios.bin vendor/v86/vgabios.bin \
  images/linux-0.01-floppy-1440k.img \
  images/linux-0.01-hda.img.gz \
  images/linux-0.01-ide-master-placeholder.img \
  images/linux-0.99.12-floppy.img \
  images/slackware-1.01-1993.raw.gz.part-000 \
  images/redhat-5.2-1998.raw.gz.part-000; do
  if [[ ! -s "$SOURCE/$file" ]]; then
    echo "REFUSING: Missing required functioning-VM asset: $SOURCE/$file" >&2
    exit 1
  fi
done
[[ "$DEPLOY" == 0 || "$DEPLOY" == 1 ]] || { echo "DEPLOY must be 0 or 1" >&2; exit 1; }
STAGING="$(mktemp -d "$ROOT/.work/video-deploy.XXXXXXXX")"
echo "Creating safe copy: $STAGING"
cp -a "$SOURCE/." "$STAGING/"

python3 - "$STAGING" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
embed = "https://www.youtube-nocookie.com/embed/GdhBmuVOcXc"

# Remove the previous video from the shared terminal homepage, if present.
homepage = root / "index.html"
home = homepage.read_text(encoding="utf-8")
start_tag = '<section class="demo-section" id="watch-demo"'
if home.count(start_tag) > 1:
    raise SystemExit("REFUSING: duplicate homepage demos")
if start_tag in home:
    start = home.index(start_tag)
    end = home.find("</section>", start)
    if end == -1:
        raise SystemExit("REFUSING: cannot locate demo closing tag")
    home = home[:start] + home[end + len("</section>"):]
home = home.replace('<a href="#watch-demo">WATCH DEMO</a>', "")
if embed in home or 'id="watch-demo"' in home:
    raise SystemExit("REFUSING: video remains on the homepage")
home, home_css_count = re.subn(r'<link rel="stylesheet" href="/style\.css\?v=[^"]+">', '<link rel="stylesheet" href="/style.css?v=20261122-nav5-visible">', home, count=1)
if home_css_count != 1:
    raise SystemExit("REFUSING: homepage stylesheet link missing")
homepage.write_text(home, encoding="utf-8")

# Insert the video on About and remove any stale link to the homepage video.
about_file = root / "about.html"
about = about_file.read_text(encoding="utf-8")
about = re.sub(r'<p>Watch the <a href="/#watch-demo">.*?</p>', "", about, count=1, flags=re.DOTALL)
if 'id="watch-demo"' not in about:
    marker = '<section class="profile-panel">'
    if about.count(marker) != 1:
        raise SystemExit("REFUSING: About insertion marker is missing or ambiguous")
    section = '''<section class="demo-section" id="watch-demo" aria-labelledby="demo-title">
<div class="section-kicker">PROJECT VIDEO / LINUX HISTORY</div>
<div class="section-heading"><h2 id="demo-title">WATCH THE <em>TIME MACHINE.</em></h2><p>Explore the history of Linux, from 1991 to today, through screenshots from the project.</p></div>
<div class="demo-video"><iframe src="https://www.youtube-nocookie.com/embed/GdhBmuVOcXc" title="Linux Time Machine — 1991 to Today — official project video" width="1600" height="900" loading="lazy" referrerpolicy="strict-origin-when-cross-origin" allow="encrypted-media; picture-in-picture; fullscreen" allowfullscreen></iframe></div>
<p class="demo-caption">The project footage shows historical x86 guests and later educational reconstructions. <a href="https://youtu.be/GdhBmuVOcXc" target="_blank" rel="noopener noreferrer">Watch on YouTube ↗</a></p>
</section>'''
    about = about.replace(marker, section + marker, 1)
if about.count(embed) != 1:
    raise SystemExit("REFUSING: About video is missing or duplicated")
# Keep the historical five-link header on About, pointing to the terminal homepage.
nav = '''<nav class="header-links"><a href="/#timeline">TIMELINE</a><a href="/#terminal-section">TERMINAL</a><a href="/developer.html">DEVELOPER</a><a href="/about.html">ABOUT</a><a href="https://github.com/hamdyaea/linux-time-machine" target="_blank" rel="noopener noreferrer">SOURCE ↗</a></nav>'''
about, nav_count = re.subn(r'<nav class="header-links">.*?</nav>', lambda _: nav, about, count=1, flags=re.DOTALL)
if nav_count != 1:
    raise SystemExit("REFUSING: About navigation missing")
if about.count(nav) != 1:
    raise SystemExit("REFUSING: About navigation mismatch")
about, about_css_count = re.subn(r'<link rel="stylesheet" href="/style\.css\?v=[^"]+">', '<link rel="stylesheet" href="/style.css?v=20261122-nav5-visible">', about, count=1)
if about_css_count != 1:
    raise SystemExit("REFUSING: About stylesheet link missing")
about_file.write_text(about, encoding="utf-8")

# Keep styling from the existing deployment if available, otherwise add it.
css_file = root / "style.css"
css = css_file.read_text(encoding="utf-8")
if ".demo-video iframe" not in css:
    css += '''
/* Video only in About */
.demo-section{margin:64px 0 76px}
.demo-video{width:100%;max-width:1180px;margin:28px auto 0;aspect-ratio:16/9;overflow:hidden;border:1px solid #3a7085;border-radius:14px;background:#050b14}
.demo-video iframe{display:block;width:100%;height:100%;border:0}
.demo-caption{max-width:1180px;margin:18px auto 0;color:#99bccc;font:13px/1.7 system-ui,sans-serif}
.demo-caption a{color:#67e3f8;text-decoration:underline}
@media(max-width:650px){.demo-section{margin:45px 0 58px}.demo-video{border-radius:8px}.demo-caption{font-size:12px}}
'''
css_file.write_text(css, encoding="utf-8")
if "/* Keep the five historical navigation" not in css:
    css += "\n/* Keep the five historical navigation links visible and consistent on every viewport. */\n@media (max-width:1050px) {\n  .site-header { height:auto; min-height:90px; flex-wrap:wrap; row-gap:12px; padding-top:14px; padding-bottom:14px; }\n  .site-header .header-links { width:100%; justify-content:center; flex-wrap:wrap; gap:10px 18px; }\n  .site-header .header-links a,\n  .site-header .header-links a:first-child,\n  .site-header .header-links a:nth-child(2),\n  .site-header .header-links a[href=\"/about.html\"] { display:inline-flex; font-size:11px; }\n}\n@media (max-width:650px) {\n  .site-header { padding:14px 12px; justify-content:center; }\n  .site-header .brand { margin-inline:auto; }\n  .site-header .header-links { gap:9px 14px; }\n  .site-header .header-links a,\n  .site-header .header-links a:first-child,\n  .site-header .header-links a:nth-child(2),\n  .site-header .header-links a[href=\"/about.html\"] { display:inline-flex; font-size:10px; letter-spacing:.08em; }\n}\n"
    css_file.write_text(css, encoding="utf-8")

# CSP: enable only About pages to frame youtube-nocookie.com.
header_file = root / "_headers"
lines = header_file.read_text(encoding="utf-8").splitlines(keepends=True)
route = None
home_rules = 0
about_rules = 0
frame = "frame-src https://www.youtube-nocookie.com; "
for i, line in enumerate(lines):
    if line.strip() and not line.startswith((" ", "\t", "#")):
        route = line.strip()
    if not line.lstrip().startswith("Content-Security-Policy:"):
        continue
    if route in ("/", "/index.html"):
        lines[i] = line.replace(frame, "")
        home_rules += 1
    elif route in ("/about", "/about.html"):
        if frame not in line:
            if "frame-src " in line or "frame-ancestors 'none'" not in line:
                raise SystemExit("REFUSING: unfamiliar About CSP")
            lines[i] = line.replace("frame-ancestors 'none'", frame + "frame-ancestors 'none'")
        about_rules += 1
if (home_rules, about_rules) != (2, 2):
    raise SystemExit("REFUSING: missing expected CSP routes")
header_file.write_text("".join(lines), encoding="utf-8")
PY

# Preserve the existing VM runtime configuration and the entire image/vendor trees.
for file in vm.js vm.html app.js eras.js; do
  cmp -s "$SOURCE/$file" "$STAGING/$file" || { echo "REFUSING: altered $file"; exit 1; }
done
diff -qr "$SOURCE/images" "$STAGING/images" >/dev/null || { echo "REFUSING: changed images"; exit 1; }
diff -qr "$SOURCE/vendor" "$STAGING/vendor" >/dev/null || { echo "REFUSING: changed emulator"; exit 1; }
! grep -q 'www.youtube-nocookie.com/embed/GdhBmuVOcXc' "$STAGING/index.html" || { echo "REFUSING: homepage still embeds the video"; exit 1; }
grep -q 'www.youtube-nocookie.com/embed/GdhBmuVOcXc' "$STAGING/about.html" || { echo "REFUSING: About embed not present"; exit 1; }

echo "PASS: VM code, images and emulator files unchanged."
echo "PASS: Video exists only on About; homepage iframe and permission removed."
echo "STAGED_DIRECTORY=$STAGING"
echo "PAGES_PROJECT=$PAGES_PROJECT PAGES_BRANCH=$PAGES_BRANCH"
if [[ "$DEPLOY" != 1 ]]; then
  echo "DRY RUN ONLY: No Cloudflare deployment performed."
  echo "After checking your Cloudflare Pages project + production branch, rerun:"
  echo "DEPLOY=1 PAGES_PROJECT='$PAGES_PROJECT' PAGES_BRANCH='$PAGES_BRANCH' bash /tmp/ltm-deploy-video-safely.sh"
  exit 0
fi

command -v node >/dev/null || { echo "REFUSING: Node.js is missing"; exit 1; }
command -v npx >/dev/null || { echo "REFUSING: npm/npx is missing"; exit 1; }
command -v curl >/dev/null || { echo "REFUSING: curl missing"; exit 1; }
REMOTE_HASHES="$(mktemp)"
trap 'rm -f "$REMOTE_HASHES"' EXIT
curl -fsSL --max-time 40 "https://linuxtimemachine.org/SHA256SUMS" -o "$REMOTE_HASHES"
cmp -s "$REMOTE_HASHES" "$SOURCE/SHA256SUMS" || { echo "REFUSING: production VM SHA256SUMS differs from local bundle"; exit 1; }
(cd "$STAGING" && sha256sum -c SHA256SUMS) || { echo "REFUSING: VM asset checksum mismatch"; exit 1; }
echo "Deploying complete preserved Pages bundle via Wrangler..."
npx --yes wrangler@latest pages deploy "$STAGING" --project-name="$PAGES_PROJECT" --branch="$PAGES_BRANCH"
echo "Cloudflare accepted the upload. Now verify live 1991, 1993, 1998 and 2004 boots, plus /about#watch-demo."
