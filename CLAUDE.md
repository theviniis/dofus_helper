# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

AutoHotkey v2.0 automation scripts for the game **Dofus**. Pixel-based UI detection drives multi-account workflows (zap travel, macro broadcast) without external dependencies. Runs on Windows only — no build step, no tests, no linter.

To run: double-click `index.ahk` or launch via `AutoHotkey.exe index.ahk`.

## Architecture

`index.ahk` is the DI composition root and hotkey registry. It loads `config.json`, wires all classes via `Init`, and binds hotkeys.

`src/utils/init.ahk` — `Init` class that constructs all dependencies:
- `ClientInterface` (client.ahk) — thin wrapper over AHK builtins: `WinActivate`, `PixelGetColor`, `Click`, `Send`
- `AccountManager` (account.ahk) — maps short account names → window titles; `getOpenAccounts()` returns only currently open windows
- `ZapNavigator` (zap.ahk) — uses pixel detection (`pixelMatches`) to navigate the Zap item UI; `use()` handles single account, `useAll()` loops all open accounts
- `TravelNavigator` (travel.ahk) — sends `/travel x,y` chat command via `ClientInterface`
- `TravelHistory` (travel_history.ahk) — reads/writes `history.txt`; deduplicated, max 10 entries
- `MacroBroadcaster` (macro_broadcaster.ahk) — records keyboard/mouse input, then replays on all open accounts except the origin

**Data flow:** Hotkey → class method → `config.json` lookup → AHK UI interaction

## Config (`config.json`)

```json
{
  "accounts": { "shortName": "Full Dofus Window Title" },
  "travelersBag": {
    "zap":          { "click": [x, y], "detect": { "pos": [x, y], "color": "0xRRGGBB" } },
    "zapInterface": { "detect": { "pos": [x, y], "color": "0xRRGGBB" } },
    "search":       { "click": [x, y] }
  }
}
```

- `click` = coordinates to click to interact with a UI element
- `detect.pos` + `detect.color` = pixel the script reads to know if a UI state is active

## Code Conventions

- AutoHotkey v2.0 syntax (`#Requires AutoHotkey v2.0` at top of every file)
- Dependency Injection — classes receive all dependencies via constructor; no globals except `SLEEP_TIME` and `MAIN_CHARACTER`
- `SLEEP_TIME` constant (200–250ms default) defined per module for timing between actions
- `#Include` paths are relative to the project root
- `MAIN_CHARACTER` in `index.ahk` is the account that gets focused after macro/travel operations

## Guardrails

- **Do not commit** without explicit user request (`NEVER COMMIT CHANGES UNLESS USER ASKS`)
- **Do not modify** `config.json` pixel coordinates or window names — requires manual in-game verification per game patch
- **Do not change** the return semantics of `ZapNavigator.use()` (returns Boolean), `ZapNavigator.useAll()`, or `AccountManager.getOpenAccounts()`
- **Do not commit** `history.txt`, `.bak` files, compiled `.exe`, or binary files
- Changes to hotkey bindings in `index.ahk` require user confirmation

## Pixel Coordinate Tooling

To capture new pixel coordinates and colors, run `src/utils/copy_pixel_color_and_position.ahk` via AHK, hover over the target pixel, and press `AltGr` (right Alt). Coordinates must be verified manually in-game before committing.

## Extending

- **New account:** add entry to `config.json` under `accounts`, add `$#N:: app.account.focus('name')` in `index.ahk`
- **New hotkey:** add `$modifier+key:: action` in `index.ahk`
- **New utility:** add to `src/utils/`, then `#Include` in `index.ahk`
- **New pixel-gated action:** add a key under `travelersBag` in `config.json`, then call `client.pixelMatches('key')` or `client.clickAt('key')`
