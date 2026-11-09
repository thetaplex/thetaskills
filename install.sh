#!/usr/bin/env bash
# Full install from a git checkout: shared skills + CLIs + hooks. Re-run after `git pull` to update.
exec bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills/new-project/scripts/setup.sh" "$@"
