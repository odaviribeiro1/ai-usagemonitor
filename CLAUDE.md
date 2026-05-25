# CLAUDE.md

Notes for Claude Code (and humans) working in this repo. This is a
**macOS-focused** redistribution of [akitaonrails/ai-usagebar](https://github.com/akitaonrails/ai-usagebar)
(MIT). Keep upstream `LICENSE` and the README attribution intact.

## What this is

A Rust binary that fetches AI plan usage per vendor and prints either a
human-readable view (`--pretty`, auto on a TTY) or one-line JSON
(`{text, tooltip, class}`). On macOS that JSON is consumed by the SwiftBar
plugins in [`macos/swiftbar/`](macos/swiftbar/) to render menu-bar items.
`ai-usagebar-tui` is a standalone tabbed terminal UI.

> The internal module `src/waybar.rs` (the JSON producer) is named for its
> origin but is **cross-platform and required** — the macOS menu bar depends
> on it. Don't remove it.

## Install / dev

- Build + install: `cargo install --path .` → `~/.cargo/bin/{ai-usagebar,ai-usagebar-tui}`.
  (`make install` is GNU-only and not used on macOS.)
- Tests: `cargo test`. Lint: `cargo clippy --all-targets -- -D warnings`.
- After editing a SwiftBar plugin: `open 'swiftbar://refreshallplugins'`.

## Invariants

- **The widget JSON path always exits 0** and falls back to a `⚠` JSON on
  error — SwiftBar/Waybar hide modules that exit non-zero.
- **Cache writes are atomic** (tempfile + rename).
- **No secrets in tracked files.** Never `cat` a credentials file
  (`~/.claude/.credentials.json`, `~/.codex/auth.json`) or `config.toml`;
  use `jq 'keys'` to inspect structure. OAuth client IDs are public, not secrets.

## macOS credentials

The Claude app stores its OAuth token in the **Keychain**, not in
`~/.claude/.credentials.json`. Export once so the `anthropic` vendor works:
`security find-generic-password -s "Claude Code-credentials" -w > ~/.claude/.credentials.json && chmod 600 ~/.claude/.credentials.json`.
OpenAI/Codex uses `~/.codex/auth.json` (no extra step).
