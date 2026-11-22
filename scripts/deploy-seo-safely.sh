#!/usr/bin/env bash
# Publish SEO metadata only, using a COPY of the existing full Cloudflare Pages bundle.
# Historical VMs, JavaScript runtime, page bodies, video and emulator remain unchanged.
# Usage from project root:
#   bash /tmp/ltm-deploy-seo-safely.sh            # read-only dry run + staging
#   DEPLOY=1 bash /tmp/ltm-deploy-seo-safely.sh   # guarded production deployment
set -Eeuo pipefail
ROOT="$(pwd)"
SOURCE="$ROOT/.work/pages-dist"
DEPLOY="$(printenv DEPLOY || echo 0)"
SEO_REF="d2ac637ff3567ad6e379532a523c98f80c629514"
RAW="https://raw.githubusercontent.com/hamdyaea/linux-time-machine/$SEO_REF"

[[ "$DEPLOY" == 0 || "$DEPLOY" == 1 ]] || { echo 'DEPLOY must be 0 or 1' >&2; exit 1; }
[[ -d "$SOURCE" ]] || { echo 'REFUSING: complete local pages-dist missing' >&2; exit 1; }
command -v python3 >/dev/null && command -v curl >/dev/null || { echo 'REFUSING: python3/curl required' >&2; exit 1; }
for file in index.html about.html developer.html vm.html app.js vm.js eras.js _headers style.css SHA256SUMS \
  vendor/v86/libv86.js vendor/v86/v86.wasm vendor/v86/seabios.bin vendor/v86/vgabios.bin \
  images/linux-0.01-floppy-1440k.img images/linux-0.01-hda.img.gz \
  images/linux-0.01-ide-master-placeholder.img images/linux-0.99.12-floppy.img \
  images/slackware-1.01-1993.raw.gz.part-000 images/redhat-5.2-1998.raw.gz.part-000; do
  [[ -s "$SOURCE/$file" ]] || { echo "REFUSING: missing $file" >&2; exit 1; }
done
(cd "$SOURCE" && sha256sum -c SHA256SUMS) || { echo 'REFUSING: bad local VM hashes' >&2; exit 1; }
mkdir -p "$ROOT/.work"
STAGING="$(mktemp -d "$ROOT/.work/seo-deploy.XXXXXXXX")"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cp -a "$SOURCE/." "$STAGING/"
mkdir -p "$STAGING/assets"

for file in index.html about.html developer.html robots.txt sitemap.xml; do
  curl -fsSL --retry 2 --max-time 40 "$RAW/$file" -o "$TMP/$file"
done
curl -fsSL --retry 2 --max-time 40 "$RAW/assets/linux-time-machine-social.png" \
  -o "$STAGING/assets/linux-time-machine-social.png"

python3 - "$TMP" "$STAGING" <<'PY'
from pathlib import Path
import re
import struct
import sys
import xml.etree.ElementTree as ET

srcdir, dist = map(Path, sys.argv[1:3])
BASE = 'https://linuxtimemachine.org'
CANONICAL = {'index.html': BASE + '/', 'about.html': BASE + '/about',
             'developer.html': BASE + '/developer'}
heads = re.compile(r'(<head\b[^>]*>)(.*?)(</head\s*>)', re.I | re.S)
metas = re.compile(r'<meta\b[^>]*>', re.I | re.S)
links = re.compile(r'<link\b[^>]*>', re.I | re.S)
titles = re.compile(r'<title\b[^>]*>.*?</title\s*>', re.I | re.S)
jsonld = re.compile(r'<script\b(?=[^>]*\btype\s*=\s*[\'\"]application/ld\+json[\'\"])[^>]*>.*?</script\s*>', re.I | re.S)

def attr(tag, name):
    m = re.search(r'\b' + re.escape(name) + r'\s*=\s*([\'\"])(.*?)\1', tag, re.I | re.S)
    return m.group(2) if m else ''

def seo_meta(tag):
    name, prop = attr(tag, 'name').lower(), attr(tag, 'property').lower()
    return name == 'description' or name.startswith('twitter:') or prop.startswith('og:')

for filename, canonical in CANONICAL.items():
    original = (dist / filename).read_text(encoding='utf-8')
    reference = (srcdir / filename).read_text(encoding='utf-8')
    h, s = heads.search(original), heads.search(reference)
    if not h or not s:
        raise SystemExit(f'REFUSING: malformed HTML head in {filename}')
    source_head, old_head = s.group(2), h.group(2)
    meta_tags = [tag for tag in metas.findall(source_head) if seo_meta(tag)]
    canonical_tags = [tag for tag in links.findall(source_head)
                      if 'canonical' in attr(tag, 'rel').lower().split()]
    source_titles = titles.findall(source_head)
    structured = jsonld.findall(source_head)
    if len(canonical_tags) != 1 or len(source_titles) != 1 or attr(canonical_tags[0], 'href') != canonical:
        raise SystemExit(f'REFUSING: invalid canonical/title for {filename}')
    if not all(any(attr(tag, k).lower() == expected for tag in meta_tags)
               for k, expected in [('name', 'description'), ('name', 'twitter:card'), ('property', 'og:image')]):
        raise SystemExit(f'REFUSING: missing social SEO source tags for {filename}')

    clean = metas.sub(lambda m: '' if seo_meta(m.group()) else m.group(), old_head)
    clean = links.sub(lambda m: '' if 'canonical' in attr(m.group(), 'rel').lower().split()
                      else m.group(), clean)
    clean = titles.sub('', clean)
    clean = jsonld.sub('', clean)
    replacement = clean + '\n' + '\n'.join(source_titles + canonical_tags + meta_tags + structured) + '\n'
    modified = original[:h.start(2)] + replacement + original[h.end(2):]
    new_h = heads.search(modified)
    if not new_h or modified[new_h.end():] != original[h.end():]:
        raise SystemExit(f'REFUSING: page body changed for {filename}')
    (dist / filename).write_text(modified, encoding='utf-8')
    print(f'PASS: only SEO <head> changed for {filename}')

for name in ('sitemap.xml', 'robots.txt'):
    (dist / name).write_bytes((srcdir / name).read_bytes())
xml = ET.fromstring((dist / 'sitemap.xml').read_bytes())
locs = {n.text.strip() for n in xml.iter() if n.tag.endswith('loc') and n.text}
if not set(CANONICAL.values()).issubset(locs):
    raise SystemExit('REFUSING: sitemap does not match canonical URLs')
if 'Sitemap: ' + BASE + '/sitemap.xml' not in (dist / 'robots.txt').read_text():
    raise SystemExit('REFUSING: missing robots sitemap reference')
image = (dist / 'assets/linux-time-machine-social.png').read_bytes()
if image[:8] != bytes.fromhex('89504e470d0a1a0a') or struct.unpack('>II', image[16:24]) != (1200, 630):
    raise SystemExit('REFUSING: social preview must be a 1200x630 PNG')
print('PASS: canonical sitemap/robots and real 1200x630 PNG')
PY

for file in vm.html vm.js app.js eras.js style.css _headers SHA256SUMS; do
  cmp -s "$SOURCE/$file" "$STAGING/$file" || { echo "REFUSING: modified $file" >&2; exit 1; }
done
diff -qr "$SOURCE/images" "$STAGING/images" >/dev/null || { echo 'REFUSING: disks differ' >&2; exit 1; }
diff -qr "$SOURCE/vendor" "$STAGING/vendor" >/dev/null || { echo 'REFUSING: emulator differs' >&2; exit 1; }
(cd "$STAGING" && sha256sum -c SHA256SUMS) || { echo 'REFUSING: VM hashes changed' >&2; exit 1; }
if find "$STAGING" -type f -size +25M -print | grep -q .; then
  echo 'REFUSING: Pages asset greater than 25 MB' >&2
  exit 1
fi
echo 'PASS: all historical VM assets, runtime, site body and CSS preserved'
echo "STAGED_DIRECTORY=$STAGING"
if [[ "$DEPLOY" != 1 ]]; then
  echo 'DRY RUN ONLY: no Cloudflare deployment'
  exit 0
fi

PROD_HASHES="$(mktemp)"
trap 'rm -rf "$TMP" "$PROD_HASHES"' EXIT
curl -fsSL --max-time 40 'https://linuxtimemachine.org/SHA256SUMS' -o "$PROD_HASHES"
cmp -s "$SOURCE/SHA256SUMS" "$PROD_HASHES" || {
  echo 'REFUSING: live VM hashes differ from the local bundle' >&2; exit 1;
}
command -v npx >/dev/null || { echo 'REFUSING: npx missing' >&2; exit 1; }
npx --yes wrangler@latest pages deploy "$STAGING" \
  --project-name=linux-time-machine --branch=main
echo 'Deployment uploaded. Run the live SEO audit and check VM boots.'
