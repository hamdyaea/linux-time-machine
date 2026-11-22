#!/usr/bin/env bash
# One-time GitHub repository discovery metadata setup (no Cloudflare deployment).
set -Eeuo pipefail
REPO="hamdyaea/linux-time-machine"
if ! command -v gh >/dev/null 2>&1; then
  echo "Missing GitHub CLI. On Manjaro: sudo pacman -S github-cli" >&2
  exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "Authenticate first with: gh auth login" >&2
  exit 1
fi

gh repo edit "$REPO" \
  --description "Explore Linux history from 1991 to today in your browser: historical x86 Linux guests, retro terminals and educational desktop recreations." \
  --homepage "https://linuxtimemachine.org/" \
  --add-topic "linux" \
  --add-topic "linux-kernel" \
  --add-topic "linux-history" \
  --add-topic "retrocomputing" \
  --add-topic "retro-computing" \
  --add-topic "x86" \
  --add-topic "emulation" \
  --add-topic "v86" \
  --add-topic "webassembly" \
  --add-topic "open-source"

gh repo view "$REPO" --json name,description,homepageUrl,repositoryTopics --jq '{name,description,homepage: .homepageUrl,topics: [.repositoryTopics[].name]}'
echo "GitHub repository About settings updated. No files or VM assets were touched."
