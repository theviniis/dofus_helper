# Trade Automation — Design Spec

**Date:** 2026-05-23
**Branch:** feat/trade

---

## Problem

Distributing items from one character to others (typically 3 receivers) requires a fully manual, repetitive trade flow per account:
1. Propose trade from source to receiver
2. Accept on receiver window
3. Add items manually
4. Confirm on source window
5. Confirm on receiver window
6. Repeat for each open account

## Goal

Automate everything except the "add items" step. A single hotkey triggers the full multi-account trade loop. A floating GUI pauses the loop while the user adds items, then resumes confirmation on both windows.

---

## Flow (per receiver account)

1. **Receiver window** — click on source character's portrait in the group panel (`groupBase + sourceIndex * groupSpacing`) → click "Propor troca" at `sourceClick + proposeMenuOffset`
2. **Source window** — pixel detection confirms trade proposal → click "Aceitar"
3. **Source window** — floating GUI appears: "Adicione os itens na troca e clique em Confirmar"
4. **User adds items manually**
5. **User clicks "Confirmar"** — GUI closes
6. **Source window** — click confirm trade button (pixel detection)
7. **Receiver window** — click confirm trade button (pixel detection)
8. Repeat from step 1 for the next receiver

If the user clicks "Cancelar" in the GUI, the entire loop aborts and focus returns to the original window.

If `proposeMenu` or `acceptButton` pixel is not detected within a 5-second timeout, the loop aborts with a tooltip error.

---

## Architecture

### New file: `src/clients/trade.ahk`

Class `TradeManager` with constructor dependencies:
- `tradeConfig` — the `"trade"` section from `config.json`
- `ClientInterface` — window focus, clicks, pixel detection, sleep
- `AccountManager` — active account detection, open account enumeration, focus by name

### Public API

| Method | Description |
|--------|-------------|
| `run()` | Hotkey entry point. Identifies source (active window), collects receivers (all other open accounts), runs the trade loop. |

### Private methods

| Method | Description |
|--------|-------------|
| `_proposeTrade(sourceName, receiverName)` | Focus receiver → calculate source portrait position from group panel (`groupBase + sourceIndex * groupSpacing`) → click "Propor troca" at `sourceClick + proposeMenuOffset` |
| `_acceptTrade()` | Focus source → wait for trade proposal pixel → click "Aceitar" |
| `_waitUserAddItems()` | Show always-on-top GUI → return `true` (Confirmar) or `false` (Cancelar) |
| `_confirmTrade(sourceName, receiverName)` | Focus source → click confirm → focus receiver → click confirm |
| `_tip(msg)` | Centered bottom tooltip, same pattern as `MacroBroadcaster._tip()` |

---

## Config (`config.json`)

New top-level key `"trade"`:

```json
"trade": {
  "groupBase": { "click": [X, Y] },
  "groupSpacing": [dX, dY],
  "proposeMenuOffset": [dX, dY],
  "acceptButton":  { "click": [X, Y], "detect": { "pos": [X, Y], "color": "0x..." } },
  "confirmButton": { "click": [X, Y], "detect": { "pos": [X, Y], "color": "0x..." } }
}
```

`groupBase.click` — posição do primeiro membro no menu de grupo (UI fixa do jogo).

`groupSpacing` — offset `[dX, dY]` entre retratos consecutivos no menu de grupo. A posição do personagem fonte é calculada como `groupBase + sourceIndex * groupSpacing`, onde `sourceIndex` é o índice 0-based do fonte em `config["accounts"]`.

`proposeMenuOffset` — offset `[dX, dY]` somado ao clique no retrato para chegar em "Propor troca" no menu de contexto. Ajustado manualmente após o primeiro teste.

Coordenadas coletadas com o utilitário `copy_pixel_color_and_position.ahk`.

---

## Hotkey

```ahk
$^+t:: app.trade.run()   ; Ctrl+Shift+T
```

Added to `index.ahk`.

---

## Wiring (`src/utils/init.ahk`)

```ahk
this.trade := TradeManager(config["trade"], this.client, this.account)
```

---

## GUI — Floating Confirmar Window

- `+AlwaysOnTop` — stays visible over the game
- Message: `"Adicione os itens na troca e clique em Confirmar"`
- **Confirmar** button (default, Enter triggers it)
- **Cancelar** button — aborts the entire loop
- Blocks the AHK thread via `while !state.done { Sleep(50) }` (same pattern as `ZapNavigator.getDestination()`)

---

## Error Handling

- Pixel timeout (5 s) for `acceptButton` — abort loop, show tooltip
- No open receiver accounts — abort immediately, no GUI shown
- User cancels GUI — abort loop, return focus to original window

---

## Out of Scope

- Selecting which accounts are receivers (all open non-source accounts are used)
- Detecting item quantity or type in the trade window
- Handling trade rejections or disconnects
