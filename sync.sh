#!/usr/bin/env bash
# Usage: ./sync.sh "what I changed"
set -e
git pull --rebase
git add -A
git commit -m "${1:-sync}" || echo "nothing new to commit"
git push
echo "synced"
