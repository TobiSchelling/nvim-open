#!/usr/bin/env bash
# Install nvim-open: symlink the script onto PATH and build the macOS app.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
BIN_DEST="$HOME/.local/bin"
BUNDLE_ID="com.tobischelling.open-in-nvim"

chmod +x "$HERE/bin/nvim-open" "$HERE/app/build-app.sh"

mkdir -p "$BIN_DEST"
ln -sf "$HERE/bin/nvim-open" "$BIN_DEST/nvim-open"
echo "Linked $BIN_DEST/nvim-open -> $HERE/bin/nvim-open"

"$HERE/app/build-app.sh"

if command -v duti >/dev/null 2>&1; then
  duti -s "$BUNDLE_ID" net.daringfireball.markdown all 2>/dev/null \
    && echo "Set 'Open in Nvim' as default for Markdown (.md)." \
    || echo "duti present but failed to set default — set it via Finder > Get Info."
else
  echo "Tip: 'brew install duti', then:"
  echo "     duti -s $BUNDLE_ID net.daringfireball.markdown all"
  echo "     to make .md open in nvim-open by default."
fi

echo
echo "Done. Ensure $BIN_DEST is on PATH, then try:  nvim-open <file>"
