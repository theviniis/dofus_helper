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

1. **Source window** — click on receiver character position (fixed coords in `config.json` per account)
2. **Detect context menu** — pixel detection confirms menu opened → click "Propor uma troca"
3. **Receiver window** — pixel detection confirms trade proposal → click "Aceitar"
4. **Source window** — floating GUI appears: "Adicione os itens na troca e clique em Confirmar"
5. **User adds items manually**
6. **User clicks "Confirmar"** — GUI closes
7. **Source window** — click confirm trade button (pixel detection)
8. **Receiver window** — click confirm trade button (pixel detection)
9. Repeat from step 1 for the next receiver

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
| `_proposeTradeToReceiver(receiverName)` | Focus source → click receiver character position → wait for context menu pixel → click "Propor uma troca" |
| `_acceptTradeOnReceiver(receiverName)` | Focus receiver → wait for trade proposal pixel → click "Aceitar" |
| `_waitUserAddItems()` | Show always-on-top GUI → return `true` (Confirmar) or `false` (Cancelar) |
| `_confirmTrade(sourceName, receiverName)` | Focus source → click confirm → focus receiver → click confirm |
| `_tip(msg)` | Centered bottom tooltip, same pattern as `MacroBroadcaster._tip()` |

---

## Config (`config.json`)

New top-level key `"trade"`:

```json
"trade": {
  "characters": {
    "iop":   { "click": [X, Y] },
    "panda": { "click": [X, Y] },
    "eni":   { "click": [X, Y] },
    "enu":   { "click": [X, Y] }
  },
  "proposeMenu":   { "click": [X, Y], "detect": { "pos": [X, Y], "color": "0x..." } },
  "acceptButton":  { "click": [X, Y], "detect": { "pos": [X, Y], "color": "0x..." } },
  "confirmButton": { "click": [X, Y], "detect": { "pos": [X, Y], "color": "0x..." } }
}
```

`characters[name].click` — screen coordinates to click that account's character in-game (same position in every window since all characters share the same map).

Coordinates are populated manually using the existing `copy_pixel_color_and_position.ahk` utility.

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

- Pixel timeout (5 s) for `proposeMenu` and `acceptButton` — abort loop, show tooltip
- No open receiver accounts — abort immediately, no GUI shown
- User cancels GUI — abort loop, return focus to original window

---

## Out of Scope

- Selecting which accounts are receivers (all open non-source accounts are used)
- Detecting item quantity or type in the trade window
- Handling trade rejections or disconnects
