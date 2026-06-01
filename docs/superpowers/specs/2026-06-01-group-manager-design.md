# GroupManager — Design Spec

**Date:** 2026-06-01

## Goal

Create a `GroupManager` class responsible for managing group interactions in Dofus. The initial scope covers position mapping of group member portraits and a toggleable overlay that displays a red square over each character. Future scope includes clicking characters to open their context menu and executing actions (follow leader, invite, kick, propose trade).

## Config

New section in `config.json`:

```json
"group": {
  "firstPos": [x, y],
  "offsetX": N
}
```

- `firstPos` — pixel coordinates of the first character portrait in the group UI
- `offsetX` — horizontal distance in pixels between consecutive character portraits

Position of character at index `i` (0-based, ordered by window Z-stack):

```
posX = firstPos[1] + i * offsetX
posY = firstPos[2]
```

## Architecture

Single class `GroupManager` in `src/clients/group.ahk`. Follows the existing DI pattern — all dependencies injected via constructor.

```ahk
class GroupManager {
    __New(groupConfig, account, client)

    toggleOverlay()       ; creates or destroys the overlay Gui
    getCharacterPos(i)    ; returns [x, y] for index i (private helper)
}
```

### Constructor parameters

| Parameter     | Type             | Source                      |
|---------------|------------------|-----------------------------|
| `groupConfig` | `Map`            | `config["group"]`           |
| `account`     | `AccountManager` | `Init` wiring               |
| `client`      | `ClientInterface`| `Init` wiring               |

## Overlay

`GroupManager` holds a `this.overlayGui` instance variable (initially unset) to track the Gui reference.

A single `Gui` with style `+ToolWindow +AlwaysOnTop -Caption +E0x20` (click-through, non-blocking) is created at screen position `(0, 0)` with full-screen dimensions. This ensures that control coordinates map directly to screen coordinates — a `Progress` control added at `x=500 y=300` appears at screen pixel `(500, 300)`. For each open account in window Z-order, a `Progress` control (20×20 px) with red color is placed at the calculated position.

`toggleOverlay()` behavior:
- `this.overlayGui` is unset → create Gui, assign to `this.overlayGui`, show
- `this.overlayGui` is set → destroy Gui, unset `this.overlayGui`

The Gui is destroyed on toggle-off (not just hidden) to avoid keeping resources allocated when inactive.

Character order is determined by `AccountManager.sortByWindowOrder(openAccounts)`, matching the visual order of windows as seen in the game group UI.

## Migrations

### `sortByWindowOrder` moves to `AccountManager`

The method currently lives in `ZapNavigator` but logically belongs to `AccountManager` (it operates on account names and window handles, with no Zap-specific logic).

- Add `sortByWindowOrder(accounts)` to `AccountManager` (`src/clients/account.ahk`)
- Remove `sortByWindowOrder` from `ZapNavigator` (`src/clients/zap.ahk`)
- Update `ZapNavigator.useAll()` to call `this.account.sortByWindowOrder(...)` instead of `this.sortByWindowOrder(...)`

## Wiring

`src/utils/init.ahk`:

```ahk
this.group := GroupManager(config["group"], this.account, this.client)
```

`index.ahk` (hotkey — exact binding defined by user):

```ahk
$^g:: app.group.toggleOverlay()
```

## Out of Scope (this spec)

- Context menu pixel detection and interaction
- Click-on-character logic
- Individual actions: follow leader, invite, kick, propose trade

These will be specified in a follow-up spec once the overlay is implemented and positions are verified in-game.
