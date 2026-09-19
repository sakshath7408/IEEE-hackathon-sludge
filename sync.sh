#!/usr/bin/env bash
# Usage: ./sync.sh "what I changed"
#
# Order matters: commit BEFORE pulling. The previous version pulled first,
# which aborts with "cannot pull with rebase: you have unstaged changes"
# every time you actually have something to sync — i.e. always.
set -e

# Stale locks are common when git is driven from more than one place.
rm -f .git/index.lock .git/HEAD.lock .git/ORIG_HEAD.lock 2>/dev/null || true

git add -A
git commit -m "${1:-sync}" || echo "nothing new to commit"
git pull --rebase
git push
echo "synced"
