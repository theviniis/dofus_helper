# Project Overview

AutoHotkey v2.0 automation scripts for the game **Dofus**, providing hotkey-based multi-account switching and coordinated travel via the "Zap" traveling item. Pixel-based UI detection drives automated workflows without external dependencies. Single hotkey (`h`) triggers sequential zap across all open accounts.

## Repository Structure

- `index.ahk` — Main entry point; hotkey bindings, DI wiring, config
- `src/clients/` — Game client automation modules (accounts, travel, zap coordinator)
- `src/utils/` — General-purpose utilities (pixel detection, tooltips)
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
- **Dependency Inversion** — `ZapCoordinator` receives dependencies via constructor
- Modules: `ZapNavigator` (UI interaction), `AccountManager` (accounts), `ZapCoordinator` (orchestration)
- Pixel coordinates and colors stored in config maps
- `#Include` for shared utilities; relative paths from project root
- No linter/formatter configured; manual review required

## Architecture Notes

```
index.ahk (hotkeys + DI composition root)
    ├── AccountManager (src/clients/accounts.ahk)
    │       ├── focus(accountName) → WinActivate
    │       └── getOpenAccounts() → array of open account names
    │
    ├── ZapNavigator (src/clients/use_zap.ahk)
    │       ├── isZapInterfaceOpen / isOnTravelScreen → pixel detection
    │       ├── use() → returns Boolean (true=success, false=cancelled)
    │       └── destination property → reused across accounts
    │
    └── ZapCoordinator (src/clients/zap_coordinator.ahk)
            ├── __New(zapNav, accountMgr) → DIP injection
            └── runAll() → orchestrates multi-account zap
```

**Data flow:** `h` hotkey → `ZapCoordinator.runAll()` → `AccountManager.getOpenAccounts()` → for each: focus + `ZapNavigator.use()`. First account prompts destination via InputBox; subsequent accounts reuse stored destination.

**Hotkeys defined in `index.ahk`:**

- `Win+1/2/3` — Focus account (iop/eni/sac)
- `h` — Trigger multi-account zap (ZapCoordinator.runAll)
- `Esc` — Stop ZapNavigator loop
- `Ctrl+Alt` — Copy current pixel color+position to clipboard

## Testing Strategy

> TODO: No automated tests configured. Manual testing required:
>
> - Test hotkey bindings in-game
> - Verify pixel coordinates match current Dofus version
> - Verify window titles in config match active game windows
> - Verify multi-account flow: InputBox appears once, all open accounts travel

## Security & Compliance

- No secrets, API keys, or credentials in repo
- Hardcoded window names in `config.accountList` (game-specific, no risk)
- Pixel color values are game UI constants, not sensitive

## Agent Guardrails

- **Never modify:** Hardcoded pixel coordinates (`config.sacoDeViagens`) — requires manual verification per game patch
- **Never modify:** Window name patterns in `config.accountList`
- **Required review:** Changes to hotkey bindings in `index.ahk`
- **Never commit:** Binary files, script backups (`.bak`), or compiled `.exe`
- **Never modify:** `ZapNavigator.use()` return semantics or `AccountManager.getOpenAccounts()` logic

## Extensibility Hooks

- `config.accountList` — Add more accounts by extending the Map
- `config.sacoDeViagens` — Reconfigure pixel positions for UI changes
- New hotkeys — Add `hotkey:: function()` pairs in `index.ahk`
- New utilities — Add to `src/utils/` and `#Include` in `index.ahk`
- Extend `ZapCoordinator` for additional multi-account workflows

## Further Reading

- `docs/superpowers/specs/2026-05-10-zap-multi-account.md` — Multi-account zap specification
- `docs/superpowers/plans/2026-05-10-zap-multi-account-plan.md` — Implementation plan
- `docs/superpowers/specs/` — All feature specifications
- `docs/superpowers/plans/` — All implementation plans

## Rules

- ⚠️ NEVER COMMIT CHANGES UNLESS USER ASKS!
