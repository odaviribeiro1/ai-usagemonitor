#!/usr/bin/env bash
#
# <bitbar.title>Claude Usage (ai-usagebar)</bitbar.title>
# <bitbar.version>1.0</bitbar.version>
# <bitbar.author>Davi Ribeiro</bitbar.author>
# <bitbar.desc>Shows Claude plan usage in the macOS menu bar via ai-usagebar.</bitbar.desc>
# <bitbar.dependencies>ai-usagebar,jq</bitbar.dependencies>
#
# SwiftBar runs plugins with a minimal environment, so set PATH explicitly.
export PATH="$HOME/.cargo/bin:/usr/bin:/bin:/opt/homebrew/bin:$PATH"

VENDOR="anthropic"
BIN="$HOME/.cargo/bin/ai-usagebar"
TUI="$HOME/.cargo/bin/ai-usagebar-tui"

strip_pango() { sed -E 's/<[^>]+>//g'; }

json="$("$BIN" --vendor "$VENDOR" --json 2>/dev/null)"

if [ -z "$json" ]; then
  echo "⚠️ Claude"
  echo "---"
  echo "ai-usagebar não respondeu"
  echo "Abrir TUI | bash=$TUI terminal=true"
  echo "Atualizar | refresh=true"
  exit 0
fi

text="$(printf '%s' "$json" | jq -r '.text')"
title="$(printf '%s' "$text" | strip_pango)"

# Menu bar title — no color, so it follows the menu bar theme (black on light, white on dark)
echo "${title} | size=13"
echo "---"

# Dropdown: the detailed box, colored per line (SwiftBar allows one color per line).
# Read RAW Pango lines, pick a representative color, then strip the markup.
printf '%s' "$json" | jq -r '.tooltip' | while IFS= read -r line; do
  disp="$(printf '%s' "$line" | strip_pango)"
  # Last meaningful color, ignoring the box border (#61afef) and empty-bar fill
  # (#3e4451). Border/blank-only lines stay blue.
  chosen=""
  for c in $(printf '%s' "$line" | grep -oE '#[0-9a-fA-F]{6}'); do
    case "$c" in
      '#61afef'|'#3e4451') ;;
      *) chosen="$c" ;;
    esac
  done
  [ -z "$chosen" ] && chosen="#61afef"
  # section labels (#abb2bf) are faint on light mode; show them in the accent blue
  [ "$chosen" = "#abb2bf" ] && chosen="#61afef"
  printf "%s | color=%s font='Hack Nerd Font Mono' size=12 trim=false\n" "$disp" "$chosen"
done

echo "---"
echo "Abrir TUI completa | bash=$TUI terminal=true"
echo "Atualizar agora | refresh=true"
echo "Mostrar / ocultar o item do GPT | bash=/usr/bin/open param1=swiftbar://toggleplugin?name=openai-usage.5m.sh terminal=false"
