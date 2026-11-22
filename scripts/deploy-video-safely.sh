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
  index.html about.html style.css _headers vm.js vm.html app.js eras.js \
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
import sys
root = Path(sys.argv[1])
youtube = "GdhBmuVOcXc"
index = root / "index.html"
page = index.read_text(encoding="utf-8")
if 'id="watch-demo"' not in page:
    marker = '<section class="history-archive"'
    if page.count(marker) != 1:
        raise SystemExit("REFUSING: missing or ambiguous homepage insertion marker")
    section = '''<section class="demo-section" id="watch-demo" aria-labelledby="demo-title">
<div class="section-kicker">PROJECT VIDEO / LINUX HISTORY</div>
<div class="section-heading"><h2 id="demo-title">WATCH THE <em>TIME MACHINE.</em></h2>
<p>Experience Linux Time Machine across the decades, using screenshots from historical x86 guest environments and educational desktop recreations.</p></div>
<div class="demo-video"><iframe src="https://www.youtube-nocookie.com/embed/GdhBmuVOcXc"
title="Linux Time Machine — 1991 to Today — official project video"
width="1600" height="900" loading="lazy" referrerpolicy="strict-origin-when-cross-origin"
allow="encrypted-media; picture-in-picture; fullscreen" allowfullscreen></iframe></div>
<p class="demo-caption">Actual project screenshots; historical x86 guests and later educational recreations are distinct.
<a href="https://youtu.be/GdhBmuVOcXc" target="_blank" rel="noopener noreferrer">Watch on YouTube ↗</a></p>
</section>
'''
    page = page.replace(marker, section + marker, 1)
    nav_anchor = '<a href="#timeline">TIMELINE</a>'
    if nav_anchor in page and 'href="#watch-demo"' not in page:
        page = page.replace(nav_anchor, nav_anchor + '<a href="#watch-demo">WATCH DEMO</a>', 1)
    index.write_text(page, encoding="utf-8")

css_path = root / 'style.css'
css = css_path.read_text(encoding='utf-8')
if '/* Video showcase (non-VM) */' not in css:
    css += '''
/* Video showcase (non-VM) */
.demo-section{margin:64px 0 76px}
.demo-video{width:100%;max-width:1180px;margin:28px auto 0;aspect-ratio:16/9;overflow:hidden;border:1px solid #3a7085;border-radius:14px;background:#050b14}
.demo-video iframe{display:block;width:100%;height:100%;border:0}
.demo-caption{max-width:1180px;margin:18px auto 0;color:#99bccc;font:13px/1.7 system-ui,sans-serif}
.demo-caption a{color:#67e3f8;text-decoration:underline}
@media(max-width:650px){.demo-section{margin:45px 0 58px}.demo-video{border-radius:8px}.demo-caption{font-size:12px}}
'''
    css_path.write_text(css, encoding='utf-8')

about_path = root / 'about.html'
about = about_path.read_text(encoding='utf-8')
if youtube not in about:
    anchor = '<p>Created and maintained by <strong>Hamdy Abou El Anein</strong>.'
    if about.count(anchor) != 1:
        raise SystemExit("REFUSING: about.html marker missing or ambiguous")
    about = about.replace(anchor, '<p>Watch the <a href="/#watch-demo">official Linux Time Machine video</a> or <a href="https://youtu.be/GdhBmuVOcXc" target="_blank" rel="noopener noreferrer">open it on YouTube</a>.</p>' + anchor, 1)
    about_path.write_text(about, encoding='utf-8')

headers_path = root / '_headers'
headers = headers_path.read_text(encoding='utf-8')
lines = headers.splitlines(keepends=True)
route = None
updated = 0
for n, line in enumerate(lines):
    if line.strip() and not line.startswith((' ', '\t', '#')):
        route = line.strip()
    if route in ('/', '/index.html') and line.lstrip().startswith('Content-Security-Policy:'):
        if 'https://www.youtube-nocookie.com' not in line:
            if 'frame-src ' in line:
                line = line.replace('frame-src ', 'frame-src https://www.youtube-nocookie.com ', 1)
            elif "frame-ancestors 'none'" in line:
                line = line.replace("frame-ancestors 'none'", "frame-src https://www.youtube-nocookie.com; frame-ancestors 'none'", 1)
            else:
                raise SystemExit("REFUSING: unfamiliar CSP on homepage")
            lines[n] = line
        updated += 1
if updated != 2:
    raise SystemExit(f"REFUSING: expected 2 homepage CSP rules, found {updated}")
headers_path.write_text(''.join(lines), encoding='utf-8')
PY

# Preserve the existing VM runtime configuration and the entire image/vendor trees.
for file in vm.js vm.html app.js eras.js; do
  cmp -s "$SOURCE/$file" "$STAGING/$file" || { echo "REFUSING: altered $file"; exit 1; }
done
diff -qr "$SOURCE/images" "$STAGING/images" >/dev/null || { echo "REFUSING: changed images"; exit 1; }
diff -qr "$SOURCE/vendor" "$STAGING/vendor" >/dev/null || { echo "REFUSING: changed emulator"; exit 1; }
grep -q 'www.youtube-nocookie.com/embed/GdhBmuVOcXc' "$STAGING/index.html" || { echo "REFUSING: embed not present"; exit 1; }

echo "PASS: VM code, images and emulator files unchanged."
echo "PASS: YouTube video and homepage CSP staged."
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
echo "Deploying complete preserved Pages bundle via Wrangler..."
npx --yes wrangler@latest pages deploy "$STAGING" --project-name="$PAGES_PROJECT" --branch="$PAGES_BRANCH"
echo "Cloudflare accepted the upload. Now verify live 1991, 1993, 1998 and 2004 boots, plus /#watch-demo."
