# nvim-open

Open files in **Neovim inside a Ghostty window** — as a parallel-safe replacement
for Neovide when you want a GUI window around terminal Neovim (LazyVim and all).

By default every file lands as a **tab in one shared Ghostty + Neovim window**,
driven by a persistent `nvim --listen` server. Many concurrent calls (e.g. an
agent opening several files at once) converge on that single window instead of
spawning a storm of GUI windows — the main pain point with `neovide <file>`,
where each call boots a separate embedded Neovim + GPU renderer.

## Why

- **Parallel-safe.** A `mkdir` spinlock serializes the check-or-launch step, then
  the launcher holds the lock until the server socket is live, so racing callers
  `--remote` their files into the same window.
- **Lighter than Neovide.** A real terminal (Ghostty) around `nvim`, no embedded
  GPU renderer. You get the full LazyVim experience, ligatures, your theme, etc.
- **Finder integration.** Ships an `Open in Nvim.app` shim so files open from
  Finder's *Open With* / double-click, routed through the same single window.

## Requirements

- macOS
- [Ghostty](https://ghostty.org) (`/Applications/Ghostty.app`)
- Neovim (`nvim`) on `PATH`
- `python3` (used only to resolve absolute paths)
- Optional: [`duti`](https://github.com/moretension/duti) to set the default
  Finder handler for a file type from the CLI

## Install

```bash
git clone https://github.com/TobiSchelling/nvim-open.git
cd nvim-open
./install.sh
```

`install.sh` symlinks `bin/nvim-open` into `~/.local/bin` and builds
`~/Applications/Open in Nvim.app` (registering it with Launch Services). Make
sure `~/.local/bin` is on your `PATH`.

## Usage

```bash
nvim-open file.md                 # open as a tab in the shared window
nvim-open a.md b.md c.md          # all three as tabs in one window
nvim-open                         # blank shared window
nvim-open -w file1 file2          # one Ghostty window per file
nvim-open -h                      # help
```

`GHOSTTY_BIN` and `NVIM_BIN` env vars override binary locations.

### Finder "Open With"

After install, right-click a file → **Open With** → **Open in Nvim**. To make it
the **default** for the file types you usually edit (json, txt, md, py):

```bash
./app/set-defaults.sh        # requires duti: brew install duti
```

Edit the `UTIS` list in `app/set-defaults.sh` to add more types. Verify with
`duti -d <uti>` (note: `duti -x <ext>` can show a stale cache even after the
change applies). Or set it per-type in Finder → *Get Info* → *Open With* →
*Change All…*

### Use from an agent / script

Replace any `neovide <file>` call with `nvim-open <file>`. Concurrent calls are
safe and all land in the one window.

## How it works

- Shared server socket: `${XDG_CACHE_HOME:-~/.cache}/nvim-open/server.sock`
- Liveness probe: `nvim --server <sock> --remote-expr '1'`
- Open into existing window: `nvim --server <sock> --remote-tab <files>`
- Launch new server window: `open -na Ghostty.app --args --window-save-state=never -e nvim -p --listen <sock> <files>`
- Window raise: `osascript -e 'tell application "Ghostty" to activate'`

On macOS the terminal can only be started via `open` (running the `ghostty`
binary directly with `-e` is unsupported and mis-handles arguments). Because
`open` needs `-n` to accept `--args` when Ghostty is already running, nvim-open's
editor window lives in a **dedicated Ghostty instance**, separate from your
interactive Ghostty. It's bounded at one editor instance — every file you open
shares it through the server, so you never get a window/instance storm.
`--window-save-state=never` keeps a previously-saved split layout from being
restored into the editor window. (Ghostty's `+new-window` IPC, which would let
this reuse your main instance, isn't supported on macOS as of Ghostty 1.3.x.)

## License

MIT — see [LICENSE](LICENSE).
