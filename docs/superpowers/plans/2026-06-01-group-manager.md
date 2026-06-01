# GroupManager Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a `GroupManager` class that maps group character portrait positions and renders a toggleable click-through overlay with a red square over each character.

**Architecture:** Single `GroupManager` class in `src/clients/group.ahk`, injected with `AccountManager` and `ClientInterface`. `AccountManager` gains `sortByWindowOrder` (migrated from `ZapNavigator`). The overlay is an AHK v2 `Gui` with `+E0x20` (click-through) and a transparent black background; red `Progress` controls represent each character at positions derived from `config["group"]["firstPos"]` and `config["group"]["offsetX"]`.

**Tech Stack:** AutoHotkey v2.0, AHK built-in `Gui`, `WinSetTransColor`, `WinGetList`

---

## File Map

| Action | File | Purpose |
|--------|------|---------|
| Modify | `src/clients/account.ahk` | Add `sortByWindowOrder(accounts)` |
| Modify | `src/clients/zap.ahk` | Remove `sortByWindowOrder`, update `useAll()` call |
| Create | `src/clients/group.ahk` | `GroupManager` class with overlay |
| Modify | `src/utils/init.ahk` | `#Include` group.ahk + wire `GroupManager` |
| Modify | `index.ahk` | Add toggle hotkey |
| Modify | `config.json` | Add `"group"` section with placeholder values |

---

## Task 1: Migrate `sortByWindowOrder` to `AccountManager`

**Files:**
- Modify: `src/clients/account.ahk`
- Modify: `src/clients/zap.ahk`

- [ ] **Step 1: Add `sortByWindowOrder` to `AccountManager`**

Open `src/clients/account.ahk` and add the method after `getAccountByWindow`. Final file content:

```ahk
#Requires AutoHotkey v2.0

class AccountManager {
    __New(account, client) {
        this.account := account
        this.client := client
    }

    focus(accountName) {
        windowName := this.account.Get(accountName)
        this.client.waitWindow(windowName)
        this.client.focusWindow(windowName)
    }

    getOpenAccounts() {
        openAccounts := []
        for accountName, windowName in this.account {
            if this.client.windowExists(windowName) {
                openAccounts.Push(accountName)
            }
        }
        return openAccounts
    }

    getAccountByWindow(windowId) {
        for accountName, windowName in this.account {
            if WinExist(windowName) = windowId {
                return accountName
            }
        }
        return ""
    }

    sortByWindowOrder(accounts) {
        allWindows := WinGetList()
        zOrder := Map()
        for idx, hwnd in allWindows {
            zOrder[hwnd] := idx
        }

        entries := []
        for accountName in accounts {
            windowName := this.account.Get(accountName)
            hwnd := WinExist(windowName)
            pos := (hwnd && zOrder.Has(hwnd)) ? zOrder[hwnd] : 0
            entries.Push({ name: accountName, pos: pos })
        }

        ; Descending by pos: higher idx = lower in Z-stack = opened first
        n := entries.Length
        loop n - 1 {
            i := A_Index
            loop n - i {
                j := A_Index
                if (entries[j].pos < entries[j + 1].pos) {
                    temp := entries[j]
                    entries[j] := entries[j + 1]
                    entries[j + 1] := temp
                }
            }
        }

        sorted := []
        for entry in entries {
            sorted.Push(entry.name)
        }
        return sorted
    }
}
```

- [ ] **Step 2: Update `ZapNavigator` to delegate to `AccountManager`**

In `src/clients/zap.ahk`, make two changes:

1. In `useAll()` (line 296), change:
   ```ahk
   orderedAccounts := this.sortByWindowOrder(this.selectedAccounts)
   ```
   to:
   ```ahk
   orderedAccounts := this.account.sortByWindowOrder(this.selectedAccounts)
   ```

2. Remove the entire `sortByWindowOrder` method (lines 246–280).

- [ ] **Step 3: Verify the file looks correct**

After editing, `src/clients/zap.ahk` should have no `sortByWindowOrder` method. The `useAll()` method should call `this.account.sortByWindowOrder(...)`. Confirm by reading the file — `sortByWindowOrder` must not appear anywhere in `zap.ahk`.

- [ ] **Step 4: Commit**

```bash
git add src/clients/account.ahk src/clients/zap.ahk
git commit -m "refactor: move sortByWindowOrder from ZapNavigator to AccountManager"
```

---

## Task 2: Create `GroupManager`

**Files:**
- Create: `src/clients/group.ahk`

- [ ] **Step 1: Create `src/clients/group.ahk`**

```ahk
#Requires AutoHotkey v2.0

class GroupManager {
    __New(groupConfig, account, client) {
        this.groupConfig := groupConfig
        this.account := account
        this.client := client
        this.overlayGui := ""
    }

    toggleOverlay() {
        if (this.overlayGui != "") {
            this.overlayGui.Destroy()
            this.overlayGui := ""
            return
        }

        this.overlayGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        this.overlayGui.BackColor := "000000"

        openAccounts := this.account.getOpenAccounts()
        orderedAccounts := this.account.sortByWindowOrder(openAccounts)

        loop orderedAccounts.Length {
            pos := this.getCharacterPos(A_Index - 1)
            this.overlayGui.Add("Progress", "x" pos[1] " y" pos[2] " w20 h20 cFF0000 Background000000 Range0-100", 100)
        }

        this.overlayGui.Show("x0 y0 w" A_ScreenWidth " h" A_ScreenHeight " NoActivate")
        WinSetTransColor("000000", "ahk_id " this.overlayGui.Hwnd)
    }

    getCharacterPos(i) {
        firstPos := this.groupConfig["firstPos"]
        offsetX := this.groupConfig["offsetX"]
        return [firstPos[1] + i * offsetX, firstPos[2]]
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add src/clients/group.ahk
git commit -m "feat: add GroupManager with toggleable overlay"
```

---

## Task 3: Wire `GroupManager`, add hotkey, and add config placeholder

**Files:**
- Modify: `src/utils/init.ahk`
- Modify: `index.ahk`
- Modify: `config.json`

- [ ] **Step 1: Add `#Include` and wire `GroupManager` in `init.ahk`**

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

class Init {
    __New(config, mainCharacter) {
        this.client    := ClientInterface(config)
        this.account   := AccountManager(config["accounts"], this.client)
        this.zap       := ZapNavigator(config["travelersBag"], this.client, TravelHistory(), this.account)
        this.travel    := TravelNavigator(this.client, this.account, mainCharacter)
        this.macro     := MacroBroadcaster(this.account, this.client)
        this.group     := GroupManager(config["group"], this.account, this.client)
    }
}
```

- [ ] **Step 2: Add hotkey in `index.ahk`**

Add the following line in `index.ahk` under the `; MACRO RECORDER` block (or any logical grouping):

```ahk
; GROUP OVERLAY
$^g:: app.group.toggleOverlay()
```

- [ ] **Step 3: Add placeholder `group` section in `config.json`**

Add after the `"travelersBag"` block. The `firstPos` and `offsetX` values are placeholders — **they must be replaced with real in-game coordinates** using `src/utils/copy_pixel_color_and_position.ahk` before the overlay will appear in the correct position.

```json
{
  "accounts": { ... },
  "travelersBag": { ... },
  "group": {
    "firstPos": [0, 0],
    "offsetX": 0
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add src/utils/init.ahk index.ahk config.json
git commit -m "feat: wire GroupManager into Init and add overlay toggle hotkey"
```

---

## After Implementation

Before using the overlay in-game:

1. Run `src/utils/copy_pixel_color_and_position.ahk` via AHK
2. Hover over the **first** character portrait in the Dofus group UI and press `AltGr` to copy its coordinates
3. Measure (or estimate) the horizontal distance to the **second** portrait — that is `offsetX`
4. Replace the placeholder `[0, 0]` and `0` values in `config.json` with the real values
5. Reload the script (`index.ahk`) and press `Ctrl+G` to toggle the overlay — red squares should appear over each character portrait
