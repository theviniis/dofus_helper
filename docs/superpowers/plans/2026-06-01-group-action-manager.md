# GroupActionManager Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a `GroupActionManager` class that renders a persistent always-on-top GUI with group action buttons (follow leader, invite, kick, propose trade) per character, and executes each action by right-clicking the character portrait, detecting the context menu via pixel, and clicking the desired option.

**Architecture:** Single class `GroupActionManager` in `src/clients/group_action.ahk`, injected with `groupConfig`, `AccountManager`, and `ClientInterface`. The GUI is built at startup via `showGui()` called from `Init.__New()`. Action methods calculate portrait coordinates, right-click, poll for menu via pixel detection, then click the menu option using a fixed X offset and per-action Y offset from config.

**Tech Stack:** AutoHotkey v2.0, AHK built-in `Gui`, `MouseClick`, `PixelGetColor`, `ObjBindMethod`

---

## File Map

| Action | File | Purpose |
|--------|------|---------|
| Modify | `config.json` | Add `gui` and `menu` sub-sections under `"group"` |
| Create | `src/clients/group_action.ahk` | `GroupActionManager` class |
| Modify | `src/utils/init.ahk` | `#Include` group_action.ahk + wire `GroupActionManager` |

---

## Task 1: Add config placeholders

**Files:**
- Modify: `config.json`

- [ ] **Step 1: Add `gui` and `menu` to the `"group"` section**

Replace the current `"group"` section with:

```json
"group": {
  "firstPos": [2049, 1362],
  "offsetX": 80,
  "gui": {
    "x": 100,
    "y": 100
  },
  "menu": {
    "detect":       { "offsetPos": [0, 0], "color": "0x000000" },
    "offsetX":      0,
    "followLeader": { "offsetY": 0 },
    "invite":       { "offsetY": 0 },
    "kick":         { "offsetY": 0 },
    "proposeTrade": { "offsetY": 0 }
  }
}
```

All `offsetPos`, `offsetX`, `offsetY`, and `color` values are placeholders — they must be replaced with real in-game values using `src/utils/copy_pixel_color_and_position.ahk` before the actions will work correctly.

- [ ] **Step 2: Commit**

```bash
git add config.json
git commit -m "feat: add gui and menu placeholder config for GroupActionManager"
```

---

## Task 2: Create `GroupActionManager`

**Files:**
- Create: `src/clients/group_action.ahk`

- [ ] **Step 1: Create `src/clients/group_action.ahk`**

```ahk
#Requires AutoHotkey v2.0

class GroupActionManager {
    __New(groupConfig, account, client) {
        this.groupConfig := groupConfig
        this.account := account
        this.client := client
    }

    showGui() {
        openAccounts := this.account.getOpenAccounts()
        orderedAccounts := this.account.sortByWindowOrder(openAccounts)

        myGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        myGui.SetFont("s9")

        rowH := 30
        btnW := 90
        labelW := 60
        padding := 5

        loop orderedAccounts.Length {
            i := A_Index - 1
            accountName := orderedAccounts[A_Index]
            y := padding + i * rowH

            myGui.Add("Text", "x" padding " y" (y + 6) " w" labelW, accountName)

            xBtn := padding + labelW + 5
            followBtn := myGui.Add("Button", "x" xBtn " y" y " w" btnW, "Seguir líder")
            followBtn.OnEvent("Click", ObjBindMethod(this, "followLeader", i))

            inviteBtn := myGui.Add("Button", "x+5 y" y " w" btnW, "Convidar")
            inviteBtn.OnEvent("Click", ObjBindMethod(this, "invite", i))

            kickBtn := myGui.Add("Button", "x+5 y" y " w" btnW, "Expulsar")
            kickBtn.OnEvent("Click", ObjBindMethod(this, "kick", i))

            tradeBtn := myGui.Add("Button", "x+5 y" y " w" btnW, "Propor troca")
            tradeBtn.OnEvent("Click", ObjBindMethod(this, "proposeTrade", i))
        }

        guiX := this.groupConfig["gui"]["x"]
        guiY := this.groupConfig["gui"]["y"]
        myGui.Show("x" guiX " y" guiY " NoActivate")
    }

    followLeader(i, *) {
        portraitX := this.groupConfig["firstPos"][1] + i * this.groupConfig["offsetX"]
        portraitY := this.groupConfig["firstPos"][2]
        this.clickPortrait(portraitX, portraitY)
        if (!this.waitForMenu(portraitX, portraitY))
            return
        this.clickMenuOption(portraitX, portraitY, "followLeader")
    }

    invite(i, *) {
        portraitX := this.groupConfig["firstPos"][1] + i * this.groupConfig["offsetX"]
        portraitY := this.groupConfig["firstPos"][2]
        this.clickPortrait(portraitX, portraitY)
        if (!this.waitForMenu(portraitX, portraitY))
            return
        this.clickMenuOption(portraitX, portraitY, "invite")
    }

    kick(i, *) {
        portraitX := this.groupConfig["firstPos"][1] + i * this.groupConfig["offsetX"]
        portraitY := this.groupConfig["firstPos"][2]
        this.clickPortrait(portraitX, portraitY)
        if (!this.waitForMenu(portraitX, portraitY))
            return
        this.clickMenuOption(portraitX, portraitY, "kick")
    }

    proposeTrade(i, *) {
        portraitX := this.groupConfig["firstPos"][1] + i * this.groupConfig["offsetX"]
        portraitY := this.groupConfig["firstPos"][2]
        this.clickPortrait(portraitX, portraitY)
        if (!this.waitForMenu(portraitX, portraitY))
            return
        this.clickMenuOption(portraitX, portraitY, "proposeTrade")
    }

    clickPortrait(portraitX, portraitY) {
        MouseClick("Right", portraitX, portraitY)
    }

    waitForMenu(portraitX, portraitY) {
        detect := this.groupConfig["menu"]["detect"]
        checkX := portraitX + detect["offsetPos"][1]
        checkY := portraitY + detect["offsetPos"][2]
        color := detect["color"]
        deadline := A_TickCount + 500
        while (A_TickCount < deadline) {
            if (PixelGetColor(checkX, checkY) == color)
                return true
            Sleep(SLEEP_TIME)
        }
        return false
    }

    clickMenuOption(portraitX, portraitY, action) {
        menu := this.groupConfig["menu"]
        optX := portraitX + menu["offsetX"]
        optY := portraitY + menu[action]["offsetY"]
        Click(optX, optY)
    }
}
```

**Notes for implementer:**
- `ObjBindMethod(this, "followLeader", i)` creates a bound function that calls `this.followLeader(i, ctrl, info)` when the GUI event fires — the `*` in `followLeader(i, *)` absorbs the extra GUI callback params.
- `"x+5 y" y " w" btnW` is AHK v2 implicit string concatenation — `x+5` positions the button 5px to the right of the previous control.
- `SLEEP_TIME` is a global constant (200ms) defined in the existing codebase — no need to redeclare it.
- `MouseClick("Right", x, y)` performs a right-click at the given screen coordinates.

- [ ] **Step 2: Verify the file looks correct**

Read `src/clients/group_action.ahk` and confirm:
- Class has 9 methods: `showGui`, `followLeader`, `invite`, `kick`, `proposeTrade`, `clickPortrait`, `waitForMenu`, `clickMenuOption`
- `ObjBindMethod` is used for all 4 button callbacks per row
- `waitForMenu` has a 500ms timeout loop
- `clickMenuOption` uses `menu["offsetX"]` for X and `menu[action]["offsetY"]` for Y

- [ ] **Step 3: Commit**

```bash
git add src/clients/group_action.ahk
git commit -m "feat: add GroupActionManager with persistent GUI and group actions"
```

---

## Task 3: Wire `GroupActionManager` into `Init`

**Files:**
- Modify: `src/utils/init.ahk`

- [ ] **Step 1: Add `#Include` and wire `GroupActionManager`**

Final content of `src/utils/init.ahk`:

```ahk
#Requires AutoHotkey v2.0
#Include ../clients/client.ahk
#Include ../clients/travel_history.ahk
#Include ../clients/zap.ahk
#Include ../clients/account.ahk
#Include ../clients/travel.ahk
#Include ../clients/macro_broadcaster.ahk
#Include ../clients/group.ahk
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

- [ ] **Step 2: Commit**

```bash
git add src/utils/init.ahk
git commit -m "feat: wire GroupActionManager into Init"
```

---

## After Implementation

Before the buttons will work correctly in-game:

1. Run `src/utils/copy_pixel_color_and_position.ahk` via AHK
2. Right-click any character portrait in the group UI — hover over a pixel that appears only when the context menu is open, press `AltGr` to capture its coordinates
3. Calculate `detect.offsetPos` as `[capturedX - portraitX, capturedY - portraitY]` and fill in `detect.color`
4. For each action option in the menu, hover over the option and press `AltGr` to capture its position, then fill in `offsetX` (X distance from portrait) and `offsetY` (Y distance from portrait)
5. Reload `index.ahk` — the GUI should appear at position `(100, 100)` and buttons should trigger the actions in-game
