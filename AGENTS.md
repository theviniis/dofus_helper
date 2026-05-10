# Project Overview

AutoHotkey v2.0 automation scripts for the game **Dofus**, providing hotkey-based account switching and navigation via the "Zap" traveling item. Pixel-based UI detection drives automated workflows without external dependencies.

## Repository Structure

- `index.ahk` — Main entry point; defines hotkey bindings and configuration
- `src/utils/` — Shared utility modules (ZapNavigator, Accounts, clipboard, pixel detection)
- `docs/superpowers/` — Feature specs and implementation plans (nested by date)
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
- Classes for domain logic (`ZapNavigator`, `Accounts`, `HistoryManager`)
- Pixel coordinates and colors stored in config maps
- `#Include` for shared utilities; relative paths from project root
- No linter/formatter configured; manual review required
- Always use Solid Responsability Principle
- Always use Dependency Inversion

## Architecture Notes

```
index.ahk (hotkey bindings + config)
└── src/utils/
    ├── use_zap.ahk          (ZapNavigator class)
    ├── accounts.ahk          (Account focus logic)
    ├── does_pixel_matches.ahk (pixel color detection)
    ├── copy_window_name.ahk
    ├── copy_pixel_color_and_position.ahk
    └── send_tooltip.ahk
```

**Data flow:** Hotkey → instantiates classes from config → pixel detection loop → UI interaction (Click/Send).

**Hotkeys defined in `index.ahk`:**

- `Win+1/2/3` — Focus account (iop/eni/sac)
- `h` — Trigger ZapNavigator (travel via Zap)
- `Esc` — Stop ZapNavigator loop
- `Ctrl+Alt` — Copy current pixel color+position to clipboard

## Testing Strategy

> TODO: No automated tests configured. Manual testing required:
>
> - Test hotkey bindings in-game
> - Verify pixel coordinates match current Dofus version
> - Verify window titles in config match active game windows

## Security & Compliance

- No secrets, API keys, or credentials in repo
- Hardcoded window names in `config.accountList` (game-specific, no risk)
- Pixel color values are game UI constants, not sensitive

## Agent Guardrails

- **Never modify:** Hardcoded pixel coordinates (`config.sacoDeViagens`) — requires manual verification per game patch
- **Never modify:** Window name patterns in `config.accountList`
- **Required review:** Changes to hotkey bindings in `index.ahk`
- **Never commit:** Binary files, script backups (`.bak`), or compiled `.exe`

## Extensibility Hooks

- `config.accountList` — Add more accounts by extending the Map
- `config.sacoDeViagens` — Reconfigure pixel positions for UI changes
- New hotkeys — Add `hotkey:: function()` pairs in `index.ahk`
- New utilities — Add to `src/utils/` and `#Include` in `index.ahk`

## Rules

- ⚠️ NEVER COMMIT CHANGES UNLESS USER ASKS!
