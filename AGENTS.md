# Project Overview

AutoHotkey v2.0 automation scripts for the game **Dofus**, providing hotkey-based multi-account switching and coordinated travel via the "Zap" traveling item. Pixel-based UI detection drives automated workflows without external dependencies. Single hotkey triggers sequential zap across all open accounts.

## Repository Structure

- `index.ahk` — Main entry point; hotkey bindings, DI wiring, config loading
- `config.json` — Window names and pixel coordinates for UI detection
- `src/clients/` — Game client automation modules (ClientInterface, AccountManager, ZapNavigator, TravelNavigator, TravelHistory)
- `src/utils/` — General-purpose utilities (JSON parser, header, tooltips)
- `docs/superpowers/specs/` — Feature specifications (per date)
- `docs/superpowers/plans/` — Implementation plans (per date)
- `.vscode/` — Editor settings

## Build & Development Commands

AutoHotkey scripts run directly; no build step required.

```bash
# Run script (Windows only)
# Double-click index.ahk or run via AutoHotkey.exe
index.ahk

# No tests, linting, or CI configured
```

## Code Style & Conventions

- AutoHotkey v2.0 syntax enforced via `#Requires AutoHotkey v2.0`
- **Single Responsibility Principle** — one class, one responsibility
- **Dependency Inversion** — Classes receive dependencies via constructor
- Global constants: `SLEEP_TIME` defined per module (200-250ms default)
- Pixel coordinates and colors stored in `config.json` under `travelersBag`
- Window names in `config.json` under `accounts`
- `#Include` for shared utilities; relative paths from project root
- No linter/formatter configured; manual review required

## Architecture Notes

```
index.ahk (hotkeys + DI composition root)
    │
    ├── ClientInterface (src/clients/client.ahk)
    │       ├── focusWindow(windowName) → WinActivate
    │       ├── windowExists(windowName) → WinExist
    │       ├── clickAt(coordName) → Click coordinates from config
    │       ├── pixelMatches(coordName) → PixelGetColor comparison
    │       └── sendText/sendKey/confirm → Send keystrokes
    │
    ├── AccountManager (src/clients/accounts.ahk)
    │       ├── focus(accountName) → lookup window + focus
    │       ├── getOpenAccounts() → array of open account names
    │       └── getAccountByWindow(windowId) → reverse lookup
    │
    ├── ZapNavigator (src/clients/zap.ahk)
    │       ├── isZapInterfaceOpen / isOnTravelScreen → pixel detection
    │       ├── use(forceInput?) → single account zap (returns Boolean)
    │       ├── useAll() → multi-account zap (orchestrates all open accounts)
    │       ├── getDestination() → GUI for destination selection
    │       ├── destination property → reused across accounts
    │       └── stop() → halt running operation
    │
    ├── TravelNavigator (src/clients/travel.ahk)
    │       └── use() → coordinates via InputBox, sends /travel command
    │
    └── TravelHistory (src/clients/travel_history.ahk)
            ├── getAll() → reads history.txt
            ├── add(destination) → prepends, deduplicates, limits to 10
            └── save(destinations) → writes to history.txt
```

**Data flow:** Hotkey → Class method → config lookup → UI interaction

**Hotkeys defined in `index.ahk`:**

| Hotkey | Action |
|--------|--------|
| `Win+1` | Focus account "iop" |
| `Win+2` | Focus account "eni" |
| `Win+3` | Focus account "cra" |
| `Win+4` | Focus account "sac" |
| `Ctrl+t` | Single-account travel (TravelNavigator.use) |
| `Win+h` | Single-account zap (ZapNavigator.use) |
| `Ctrl+h` | Multi-account zap (ZapNavigator.useAll) |
| `Ctrl+Esc` | Stop ZapNavigator loop |
| `Win+c` | Copy active window name to clipboard |

## Testing Strategy

> TODO: No automated tests configured. Manual testing required:
>
> - Test hotkey bindings in-game
> - Verify pixel coordinates match current Dofus version
> - Verify window titles in config match active game windows
> - Verify multi-account flow: GUI appears once, all open accounts travel
> - Verify TravelHistory persists across sessions

## Security & Compliance

- No secrets, API keys, or credentials in repo
- Window names in `config.json` (game-specific, no risk)
- Pixel color values are game UI constants, not sensitive
- `history.txt` excluded from git (runtime data)

## Agent Guardrails

- **Never modify:** Hardcoded pixel coordinates in `config.json` (`travelersBag`) — requires manual verification per game patch
- **Never modify:** Window name patterns in `config.json` (`accounts`)
- **Required review:** Changes to hotkey bindings in `index.ahk`
- **Never commit:** Binary files, script backups (`.bak`), compiled `.exe`, `history.txt`
- **Never modify:** Return semantics of `ZapNavigator.use()`, `ZapNavigator.useAll()`, or `AccountManager.getOpenAccounts()`

## Extensibility Hooks

- `config.json` — Add more accounts under `accounts`, reconfigure pixels under `travelersBag`
- New hotkeys — Add `hotkey:: function()` pairs in `index.ahk`
- New utilities — Add to `src/utils/` and `#Include` in `index.ahk`
- Extend `ZapNavigator` for additional multi-account workflows
- `TravelHistory` limit configurable via constructor (default: 10)

## Further Reading

- `docs/superpowers/specs/2026-05-10-zap-multi-account.md` — Multi-account zap specification
- `docs/superpowers/plans/2026-05-10-zap-multi-account-plan.md` — Implementation plan
- `docs/superpowers/specs/` — All feature specifications
- `docs/superpowers/plans/` — All implementation plans

## Rules

- NEVER COMMIT CHANGES UNLESS USER ASKS!