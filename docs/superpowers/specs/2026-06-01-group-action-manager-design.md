# GroupActionManager — Design Spec

**Date:** 2026-06-01

## Goal

Create a `GroupActionManager` class responsible for group interaction actions in Dofus: follow leader, invite, kick, and propose trade. It renders a persistent always-on-top GUI with one row per character and four action buttons per row. Clicking a button clicks the target character's portrait in the active game window, waits for the context menu to open (pixel detection), and clicks the desired option.

## Config

The existing `"group"` section in `config.json` gains two new sub-sections:

```json
"group": {
  "firstPos": [2049, 1362],
  "offsetX": 80,
  "gui": {
    "x": 100,
    "y": 100
  },
  "menu": {
    "detect":       { "offsetPos": [0, 0], "color": "0xRRGGBB" },
    "offsetX":      0,
    "followLeader": { "offsetY": 0 },
    "invite":       { "offsetY": 0 },
    "kick":         { "offsetY": 0 },
    "proposeTrade": { "offsetY": 0 }
  }
}
```

- `gui.x` / `gui.y` — fixed screen position of the persistent GUI window
- `menu.detect.offsetPos` — offset relative to the portrait click position used to check if the context menu opened
- `menu.detect.color` — expected pixel color when the menu is open
- `menu.offsetX` — fixed X offset from the portrait position to click any menu option
- `menu.<action>.offsetY` — Y offset from the portrait position to click the specific option

All offsets are relative to the portrait's screen position (`firstPos[1] + i * offsetX`, `firstPos[2]`).

## Architecture

Single class `GroupActionManager` in `src/clients/group_action.ahk`. Follows the existing DI pattern.

```ahk
class GroupActionManager {
    __New(groupConfig, account, client)

    showGui()                     ; creates and shows the persistent GUI (called at startup)

    followLeader(i)               ; portrait click → menu → follow leader option
    invite(i)                     ; portrait click → menu → invite option
    kick(i)                       ; portrait click → menu → kick option
    proposeTrade(i)               ; portrait click → menu → propose trade option

    clickPortrait(i)              ; clicks portrait at index i (private)
    waitForMenu(portraitX, portraitY) ; polls pixel until menu detected or timeout (private)
    clickMenuOption(portraitX, portraitY, action) ; clicks option offset for action (private)
}
```

### Constructor parameters

| Parameter     | Type             | Source                    |
|---------------|------------------|---------------------------|
| `groupConfig` | `Map`            | `config["group"]`         |
| `account`     | `AccountManager` | `Init` wiring             |
| `client`      | `ClientInterface`| `Init` wiring             |

## Persistent GUI

A `Gui` with `+AlwaysOnTop -Caption +ToolWindow` positioned at `(gui.x, gui.y)` from config. Built in `showGui()`, which is called once from `Init.__New()` so the window is always visible.

Layout — one row per open account in window Z-order:

```
iop   [Seguir líder] [Convidar] [Expulsar] [Propor troca]
panda [Seguir líder] [Convidar] [Expulsar] [Propor troca]
eni   [Seguir líder] [Convidar] [Expulsar] [Propor troca]
enu   [Seguir líder] [Convidar] [Expulsar] [Propor troca]
```

Each button's `OnEvent("Click", ...)` callback calls the corresponding action method passing the row's 0-based index `i`. The GUI is not click-through — it receives mouse input.

Account order comes from `account.sortByWindowOrder(account.getOpenAccounts())`, matching the group UI ordering.

## Action Execution Flow

When the user clicks, for example, "Expulsar" on the `panda` row (index 1):

1. Calculate portrait position: `portraitX = firstPos[1] + 1 * offsetX`, `portraitY = firstPos[2]`
2. Call `clickPortrait(1)` → `Click portraitX, portraitY, Right` (right-click opens context menu)
3. Call `waitForMenu(portraitX, portraitY)`:
   - Poll `PixelGetColor(portraitX + detect.offsetPos[1], portraitY + detect.offsetPos[2])`
   - Return `true` when color matches `detect.color`
   - Return `false` on timeout (500ms, checked every `SLEEP_TIME`)
4. If menu not detected → return without clicking
5. Call `clickMenuOption(portraitX, portraitY, "kick")`:
   - `Click(portraitX + menu.offsetX, portraitY + menu["kick"]["offsetY"])`

The action always executes in the currently focused game window. No window switching is performed.

## Wiring

`src/utils/init.ahk`:

```ahk
#Include ../clients/group_action.ahk

class Init {
    __New(config) {
        this.client      := ClientInterface(config)
        this.account     := AccountManager(config["accounts"], this.client)
        this.zap         := ZapNavigator(config["travelersBag"], this.client, TravelHistory(), this.account)
        this.travel      := TravelNavigator(this.client, this.account, this.account.mainCharacter)
        this.macro       := MacroBroadcaster(this.account, this.client)
        this.group       := GroupManager(config["group"], this.account, this.client)
        this.groupAction := GroupActionManager(config["group"], this.account, this.client)
        this.groupAction.showGui()
    }
}
```

No new hotkeys in `index.ahk` — all actions are triggered via GUI buttons.

## Out of Scope (this spec)

- Detecting which actions are valid for the current role (leader vs member) — the game will simply ignore invalid actions
- Automatic window switching before executing an action
- Error feedback to the user when the menu fails to open
