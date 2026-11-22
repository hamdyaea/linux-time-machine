#!/usr/bin/env python3
"""Audit Linux Time Machine public SEO without modifying its website or historical VMs.

Run: python3 scripts/audit-live-seo.py
This is read-only and uses only the Python standard library.
"""
from __future__ import annotations

import json
import sys
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET
from html.parser import HTMLParser
from urllib.parse import urlparse

BASE = "https://linuxtimemachine.org"
SITE_PATHS = ("/", "/about", "/developer")
EXPECTED_SITEMAP = set(BASE + path for path in SITE_PATHS)
errors = []
warnings = []


def get(path: str):
    url = BASE + path
    request = urllib.request.Request(
        url,
        headers={
            "User-Agent": "LinuxTimeMachine-SEO-Audit/1.0",
            "Accept": "*/*",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=20) as response:
            content = response.read(3_000_000)
            return response.status, response.url, response.headers.get("Content-Type", ""), content
    except (OSError, urllib.error.URLError) as exc:
        errors.append(f"{path}: HTTP request failed: {exc}")
        return 0, url, "", b""


def check(condition: bool, message: str):
    print(("PASS" if condition else "FAIL") + ": " + message)
    if not condition:
        errors.append(message)


class Head(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_title = False
        self.title = ""
        self.links = []
        self.metas = []

    def handle_starttag(self, tag, attrs):
        d = dict(attrs)
        if tag == "title":
            self.in_title = True
        elif tag == "link":
            self.links.append(d)
        elif tag == "meta":
            self.metas.append(d)

    def handle_endtag(self, tag):
        if tag == "title":
            self.in_title = False

    def handle_data(self, data):
        if self.in_title:
            self.title += data


def meta_value(doc: Head, key: str, value: str):
    return next(
        (m.get("content", "") for m in doc.metas if m.get(key, "").lower() == value),
        "",
    )


print("=== Public Linux Time Machine SEO audit (read-only) ===")
for path in SITE_PATHS:
    status, final_url, mime, body = get(path)
    if status != 200:
        check(False, f"{path}: expected HTTP 200, received {status}")
        continue
    check("text/html" in mime.lower(), f"{path}: HTML content type ({mime})")
    doc = Head()
    doc.feed(body.decode("utf-8", "replace"))
    canonical = next(
        (link.get("href", "") for link in doc.links if link.get("rel", "").lower() == "canonical"),
        "",
    )
    check(bool(doc.title.strip()), f"{path}: title present ({doc.title.strip()})")
    check(bool(meta_value(doc, "name", "description")), f"{path}: meta description present")
    check(canonical == BASE + path, f"{path}: canonical URL is {canonical!r}")
    robots = meta_value(doc, "name", "robots")
    check("noindex" not in robots.lower(), f"{path}: not marked noindex")
    print(f"INFO: {path} resolves to {final_url}")

status, url, mime, body = get("/robots.txt")
check(status == 200, f"robots.txt: HTTP {status}")
check("text/html" not in mime.lower(), "robots.txt: not an HTML fallback")
text = body.decode("utf-8", "replace")
check("User-agent:" in text, "robots.txt: has user-agent directive")
check("Sitemap: " + BASE + "/sitemap.xml" in text, "robots.txt: declares canonical sitemap")

status, url, mime, body = get("/sitemap.xml")
check(status == 200, f"sitemap.xml: HTTP {status}")
check("text/html" not in mime.lower(), "sitemap.xml: not an HTML fallback")
try:
    root = ET.fromstring(body)
    namespaces = {"s": "http://www.sitemaps.org/schemas/sitemap/0.9"}
    locs = {node.text.strip() for node in root.findall(".//s:loc", namespaces) if node.text}
    if not locs:
        locs = {node.text.strip() for node in root.iter() if node.tag.endswith("loc") and node.text}
    print("INFO: sitemap URLs: " + json.dumps(sorted(locs), ensure_ascii=False))
    check(EXPECTED_SITEMAP.issubset(locs), "sitemap.xml: homepage, About and Developer URLs present")
except ET.ParseError as exc:
    check(False, f"sitemap.xml: invalid XML ({exc})")

status, url, mime, body = get("/assets/linux-time-machine-social.png")
check(status == 200, f"social preview: HTTP {status}")
check(body.startswith(b"\x89PNG\r\n\x1a\n"), "social preview: actual PNG, not HTML fallback")

print("\n" + ("RESULT: FAIL" if errors else "RESULT: PASS"))
if errors:
    print("Errors: " + json.dumps(errors, ensure_ascii=False, indent=2))
print("Note: Google indexing status requires authenticated Google Search Console.")
print("Note: This script never changes the live site or VM assets.")
sys.exit(1 if errors else 0)
