#!/usr/bin/env bash
# Install nvim-open: symlink the script onto PATH and build the macOS app.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
BIN_DEST="$HOME/.local/bin"
BUNDLE_ID="com.tobischelling.open-in-nvim"

chmod +x "$HERE/bin/nvim-open" "$HERE/app/build-app.sh" "$HERE/app/set-defaults.sh"

mkdir -p "$BIN_DEST"
ln -sf "$HERE/bin/nvim-open" "$BIN_DEST/nvim-open"
echo "Linked $BIN_DEST/nvim-open -> $HERE/bin/nvim-open"

"$HERE/app/build-app.sh"

if command -v duti >/dev/null 2>&1; then
  "$HERE/app/set-defaults.sh" || true
else
  echo "Tip: 'brew install duti', then run ./app/set-defaults.sh to make nvim-open"
  echo "     the default for json/txt/md/py."
fi

echo
echo "Done. Ensure $BIN_DEST is on PATH, then try:  nvim-open <file>"
