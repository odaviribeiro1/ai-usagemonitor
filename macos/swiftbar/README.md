# macOS menu bar (SwiftBar)

On macOS the Waybar widget doesn't apply, but `ai-usagebar` still works as a
cross-platform TUI and as a `--json`/`--pretty` producer. These two
[SwiftBar](https://github.com/swiftbar/SwiftBar) plugins put the usage bars in
the macOS menu bar, one item per vendor.

| Plugin | Menu-bar item |
|--------|---------------|
| `claude-usage.5m.sh` | Anthropic Claude — e.g. `78% · 1h 03m` |
| `openai-usage.5m.sh` | OpenAI / Codex — e.g. `GPT 20% · 3h 54m` |

Each refreshes every 5 minutes (the `5m` in the filename), shows a monochrome
title that follows the menu-bar theme, and a colored dropdown with the full
Session / Weekly / Credits breakdown.

## Requirements

- `ai-usagebar` on your `PATH` — `cargo install --path .` from the repo root
  installs it to `~/.cargo/bin`.
- `jq` (preinstalled at `/usr/bin/jq` on modern macOS).
- [SwiftBar](https://github.com/swiftbar/SwiftBar): `brew install --cask swiftbar`.
- A Nerd Font for the dropdown glyphs: `brew install --cask font-hack-nerd-font`
  (the plugins use `Hack Nerd Font Mono`).

## Install

```bash
brew install --cask swiftbar font-hack-nerd-font
mkdir -p "$HOME/Library/Application Support/SwiftBar/Plugins"
cp claude-usage.5m.sh openai-usage.5m.sh "$HOME/Library/Application Support/SwiftBar/Plugins/"
chmod +x "$HOME/Library/Application Support/SwiftBar/Plugins/"*.sh
open -a SwiftBar      # on first launch, point it at the Plugins folder above
```

After editing a plugin, reload SwiftBar with `open 'swiftbar://refreshallplugins'`.

## Anthropic credentials on macOS

The `anthropic` vendor reads `~/.claude/.credentials.json`, but on macOS the
Claude CLI keeps its OAuth token in the **Keychain**. Export it once:

```bash
security find-generic-password -s "Claude Code-credentials" -w > ~/.claude/.credentials.json
chmod 600 ~/.claude/.credentials.json
```

The `openai` vendor reads `~/.codex/auth.json` (Codex CLI OAuth) and needs no
extra step.

## Show / hide an item

- The **GPT** item's dropdown has **"Ocultar este item (GPT)"** to hide it.
- The **Claude** item's dropdown has **"Mostrar / ocultar o item do GPT"** to
  bring it back (Claude stays visible, so it's the re-enable path).
- Or from a terminal: `open 'swiftbar://toggleplugin?name=openai-usage.5m.sh'`.
- SwiftBar's native control is hidden behind an **⌥ Option-click** on the item.

## Customize

Inside each script:

- **Refresh interval** — rename the file (`.5m.` → `.2m.`, `.1m.`, …).
- **Vendor** — change `VENDOR` (`anthropic` | `openai` | `zai` | `openrouter`).
  `zai`/`openrouter` need `ZAI_API_KEY` / `OPENROUTER_API_KEY`; export them
  inside the script since SwiftBar runs with a minimal environment.
- **Label** — the `LABEL` prefix shown in the menu bar (the OpenAI plugin uses
  `GPT ` to stay distinct from the Claude item).
