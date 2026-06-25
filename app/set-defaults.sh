#!/usr/bin/env bash
# Make "Open in Nvim" the default Finder handler for the file types you usually
# edit. Requires duti (`brew install duti`). Safe to re-run / idempotent.
#
# Verify afterwards with:  duti -d <uti>
# (Note: `duti -x <ext>` can report a stale cache even after the change applies.)
set -euo pipefail

BUNDLE_ID="com.tobischelling.open-in-nvim"

command -v duti >/dev/null 2>&1 || { echo "duti not found — run 'brew install duti' first." >&2; exit 1; }

# UTIs for the file types to route to nvim-open. Add lines as needed.
UTIS=(
  public.json                  # .json
  public.plain-text            # .txt
  net.daringfireball.markdown  # .md / .markdown
  public.python-script         # .py
)

for uti in "${UTIS[@]}"; do
  duti -s "$BUNDLE_ID" "$uti" all && printf 'default[%s] -> %s\n' "$uti" "$BUNDLE_ID"
done
