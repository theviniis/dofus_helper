# Trade Automation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Automate multi-account Dofus trade distribution — each receiver proposes a trade to the source character, user adds items via a floating GUI, automation confirms on both windows — triggered via `Ctrl+Shift+T`.

**Architecture:** New `TradeManager` class follows the same dependency-injection pattern as `ZapNavigator`. Each receiver proposes a trade to the source character (fixed screen position, same in every receiver window since all characters share the same map). A floating always-on-top GUI pauses execution while the user adds items. `ClientInterface` gains two generic pixel helpers (`pixelMatchesDetect` / `waitForPixelDetect`) so `TradeManager` can poll pixels from its own config section without going through `travelersBag`.

**Tech Stack:** AutoHotkey v2.0, `config.json` for coordinates, pixel-based UI detection

---

### File Map

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `src/clients/trade.ahk` | TradeManager class — full trade loop |
| Modify | `config.json` | Add `"trade"` section with coordinates |
| Modify | `src/clients/client.ahk` | Add `pixelMatchesDetect` and `waitForPixelDetect` |
| Modify | `src/utils/init.ahk` | Wire TradeManager into Init |
| Modify | `index.ahk` | Add `Ctrl+Shift+T` hotkey |

---

### Task 1: Add trade config skeleton to config.json

**Files:**
- Modify: `config.json`

- [ ] **Step 1: Add `"trade"` section to config.json**

Open `config.json`. Add the `"trade"` key after `"travelersBag"`. Full file after edit:

```json
{
  "accounts": {
    "iop": "Bate-no-sigilo - Iop - 3.5.17.21 - Release",
    "panda": "Tanka-no-sigilo - Pandawa - 3.5.17.21 - Release",
    "eni": "Cura-no-sigilo - Eniripsa - 3.5.17.21 - Release",
    "enu": "Dropa-No-Sigilo - Enutrof - 3.5.17.21 - Release"
  },
  "travelersBag": {
    "zap": {
      "click": [1165, 554],
      "detect": {
        "pos": [1445, 429],
        "color": "0xA75F20"
      }
    },
    "zapInterface": {
      "detect": {
        "pos": [1595, 410],
        "color": "0x173238"
      }
    },
    "search": {
      "click": [1334, 515]
    }
  },
  "trade": {
    "sourceCharacter": { "click": [0, 0] },
    "proposeMenuOffset": [0, 0],
    "acceptButton": {
      "click": [0, 0],
      "detect": { "pos": [0, 0], "color": "0x000000" }
    },
    "confirmButton": {
      "click": [0, 0],
      "detect": { "pos": [0, 0], "color": "0x000000" }
    }
  }
}
```

- [ ] **Step 2: Validate JSON**

```bash
python3 -c "import json; json.load(open('config.json')); print('OK')"
```
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add config.json
git commit -m "feat: add trade config skeleton to config.json"
```

---

### Task 2: Add pixel helpers to ClientInterface

**Files:**
- Modify: `src/clients/client.ahk`

`pixelMatches(coordName)` only works for keys under `travelersBag`. Trade config lives under `config["trade"]`, so we need helpers that accept a detect object directly.

- [ ] **Step 1: Add `pixelMatchesDetect` and `waitForPixelDetect` after the existing `pixelMatches` method**

```ahk
pixelMatchesDetect(detect) {
    pixelColor := PixelGetColor(detect['pos'][1], detect['pos'][2])
    return pixelColor == detect['color']
}

waitForPixelDetect(detect, timeoutMs := 5000) {
    deadline := A_TickCount + timeoutMs
    while A_TickCount < deadline {
        if this.pixelMatchesDetect(detect)
            return true
        Sleep(100)
    }
    return false
}
```

- [ ] **Step 2: Refactor `pixelMatches` to delegate to `pixelMatchesDetect`**

Replace the existing `pixelMatches` body:

```ahk
pixelMatches(coordName) {
    detect := this.config["travelersBag"][coordName]['detect']
    return this.pixelMatchesDetect(detect)
}
```

- [ ] **Step 3: Verify script loads**

Launch `index.ahk`. Expected: no error dialogs, tray icon appears.

- [ ] **Step 4: Commit**

```bash
git add src/clients/client.ahk
git commit -m "feat: add pixelMatchesDetect and waitForPixelDetect to ClientInterface"
```

---

### Task 3: Create TradeManager skeleton and wire up

**Files:**
- Create: `src/clients/trade.ahk`
- Modify: `src/utils/init.ahk`
- Modify: `index.ahk`

- [ ] **Step 1: Create `src/clients/trade.ahk`**

```ahk
#Requires AutoHotkey v2.0

class TradeManager {
    __New(tradeConfig, client, account) {
        this.tradeConfig := tradeConfig
        this.client      := client
        this.account     := account
    }

    run() {
    }

    _proposeTrade(receiverName) {
    }

    _acceptTrade(sourceName) {
        return false
    }

    _waitUserAddItems() {
        return false
    }

    _confirmTrade(sourceName, receiverName) {
    }

    _tip(msg) {
    }
}
```

- [ ] **Step 2: Update `src/utils/init.ahk`**

```ahk
#Requires AutoHotkey v2.0
#Include ../clients/client.ahk
#Include ../clients/travel_history.ahk
#Include ../clients/zap.ahk
#Include ../clients/account.ahk
#Include ../clients/travel.ahk
#Include ../clients/macro_broadcaster.ahk
#Include ../clients/trade.ahk

class Init {
    __New(config) {
        this.client    := ClientInterface(config)
        this.account   := AccountManager(config["accounts"], this.client)
        this.zap       := ZapNavigator(config["travelersBag"], this.client, TravelHistory(), this.account)
        this.travel    := TravelNavigator(this.client)
        this.macro     := MacroBroadcaster(this.account, this.client)
        this.trade     := TradeManager(config["trade"], this.client, this.account)
    }
}
```

- [ ] **Step 3: Add hotkey in `index.ahk`**

Add after the `; MACRO RECORDER` block:

```ahk
; TRADE
$^+t:: app.trade.run()
```

- [ ] **Step 4: Verify script loads**

Launch `index.ahk`. Expected: no error dialogs, tray icon appears, `Ctrl+Shift+T` does nothing (all stubs).

- [ ] **Step 5: Commit**

```bash
git add src/clients/trade.ahk src/utils/init.ahk index.ahk
git commit -m "feat: add TradeManager skeleton, hotkey, and wiring"
```

---

### Task 4: Implement `_tip()`

**Files:**
- Modify: `src/clients/trade.ahk`

- [ ] **Step 1: Implement `_tip()` — same pattern as `MacroBroadcaster._tip()`**

```ahk
_tip(msg) {
    BOTTOM_OFFSET := 130
    tipX := A_ScreenWidth // 2 - 150
    tipY := A_ScreenHeight - BOTTOM_OFFSET
    ToolTip(msg, tipX, tipY)
    if (msg = "")
        return
    SetTimer(() => ToolTip("", tipX, tipY), -2000)
}
```

- [ ] **Step 2: Add smoke test in `run()`**

```ahk
run() {
    this._tip("TradeManager: OK")
}
```

- [ ] **Step 3: Launch and test**

Press `Ctrl+Shift+T`. Expected: tooltip "TradeManager: OK" appears at bottom center and disappears after ~2 s.

- [ ] **Step 4: Remove smoke test**

```ahk
run() {
}
```

- [ ] **Step 5: Commit**

```bash
git add src/clients/trade.ahk
git commit -m "feat: implement TradeManager._tip()"
```

---

### Task 5: Implement `_waitUserAddItems()` GUI

**Files:**
- Modify: `src/clients/trade.ahk`

- [ ] **Step 1: Implement `_waitUserAddItems()`**

```ahk
_waitUserAddItems() {
    state := { result: false, done: false }

    myGui := Gui("+AlwaysOnTop", "Troca")
    myGui.SetFont("s10")
    myGui.Add("Text", "x10 y10 w280", "Adicione os itens na troca e clique em Confirmar.")

    OnConfirm(*) {
        state.result := true
        state.done   := true
        myGui.Destroy()
    }

    OnCancel(*) {
        state.result := false
        state.done   := true
        myGui.Destroy()
    }

    OnClose(GuiObj) {
        state.result := false
        state.done   := true
        GuiObj.Destroy()
    }

    myGui.Add("Button", "x10 y40 w80", "Cancelar").OnEvent("Click", OnCancel)
    myGui.Add("Button", "x+10 y40 w80 Default", "Confirmar").OnEvent("Click", OnConfirm)
    myGui.OnEvent("Close", OnClose)
    myGui.Show("w300")

    while !state.done {
        Sleep(50)
    }

    return state.result
}
```

- [ ] **Step 2: Add smoke test in `run()`**

```ahk
run() {
    result := this._waitUserAddItems()
    this._tip(result ? "Confirmado" : "Cancelado")
}
```

- [ ] **Step 3: Launch and test**

Press `Ctrl+Shift+T`. Verify all three cases:
- **Confirmar** button (or Enter) → tooltip "Confirmado"
- **Cancelar** button → tooltip "Cancelado"
- Close window (X) → tooltip "Cancelado"

- [ ] **Step 4: Remove smoke test**

```ahk
run() {
}
```

- [ ] **Step 5: Commit**

```bash
git add src/clients/trade.ahk
git commit -m "feat: implement TradeManager._waitUserAddItems() GUI"
```

---

### Task 6: Implement `_proposeTrade(receiverName)` and fill config coordinates

**Files:**
- Modify: `src/clients/trade.ahk`
- Modify: `config.json`

- [ ] **Step 1: Implement `_proposeTrade(receiverName)`**

```ahk
_proposeTrade(receiverName) {
    this.account.focus(receiverName)
    this.client.sleep()

    srcClick := this.tradeConfig["sourceCharacter"]["click"]
    Click(srcClick[1], srcClick[2])
    this.client.sleep()

    offset   := this.tradeConfig["proposeMenuOffset"]
    proposeX := srcClick[1] + offset[1]
    proposeY := srcClick[2] + offset[2]
    Click(proposeX, proposeY)
    this.client.sleep()
}
```

- [ ] **Step 2: Fill in `sourceCharacter.click` and `proposeMenuOffset` in config.json**

In-game, with all characters on the same map:

1. Switch to any **receiver** window (e.g., iop)
2. Run `copy_pixel_color_and_position.ahk` and hover over the source character — note the position `[srcX, srcY]`
3. Update `config.json`: `"sourceCharacter": { "click": [srcX, srcY] }`
4. Right-click the source character to open the context menu
5. Hover over "Propor troca" — note the position `[menuX, menuY]`
6. Compute offset: `[menuX - srcX, menuY - srcY]`
7. Update `config.json`: `"proposeMenuOffset": [dX, dY]`

- [ ] **Step 3: Add smoke test in `run()`**

```ahk
run() {
    sourceId     := WinExist("A")
    sourceName   := this.account.getAccountByWindow(sourceId)
    openAccounts := this.account.getOpenAccounts()

    for accountName in openAccounts {
        if (accountName = sourceName)
            continue
        this._proposeTrade(accountName)
        break
    }
}
```

- [ ] **Step 4: Launch and test**

With source window active, press `Ctrl+Shift+T`. Expected: automation switches to the first receiver window, clicks the source character, then clicks "Propor troca" in the context menu.

- [ ] **Step 5: Remove smoke test**

```ahk
run() {
}
```

- [ ] **Step 6: Commit**

```bash
git add src/clients/trade.ahk config.json
git commit -m "feat: implement TradeManager._proposeTrade() and fill sourceCharacter config"
```

---

### Task 7: Implement `_acceptTrade(sourceName)` and fill acceptButton config

**Files:**
- Modify: `src/clients/trade.ahk`
- Modify: `config.json`

- [ ] **Step 1: Fill in `acceptButton` in config.json**

In-game, manually propose a trade so the accept notification appears on the source window:

1. Switch to the source window
2. Run `copy_pixel_color_and_position.ahk` — hover over the accept button, note `[X, Y]` and the pixel color
3. Update `config.json`:
   ```json
   "acceptButton": {
       "click": [X, Y],
       "detect": { "pos": [X, Y], "color": "0xRRGGBB" }
   }
   ```

- [ ] **Step 2: Implement `_acceptTrade(sourceName)`**

```ahk
_acceptTrade(sourceName) {
    this.account.focus(sourceName)
    this.client.sleep()

    if (!this.client.waitForPixelDetect(this.tradeConfig["acceptButton"]["detect"], 5000)) {
        this._tip("Erro: proposta de troca não detectada (timeout 5s)")
        return false
    }

    acceptClick := this.tradeConfig["acceptButton"]["click"]
    Click(acceptClick[1], acceptClick[2])
    this.client.sleep()
    return true
}
```

- [ ] **Step 3: Add smoke test in `run()`**

```ahk
run() {
    sourceId     := WinExist("A")
    sourceName   := this.account.getAccountByWindow(sourceId)
    openAccounts := this.account.getOpenAccounts()

    for accountName in openAccounts {
        if (accountName = sourceName)
            continue
        this._proposeTrade(accountName)
        accepted := this._acceptTrade(sourceName)
        this._tip(accepted ? "Aceito!" : "Erro: não aceito")
        break
    }
}
```

- [ ] **Step 4: Launch and test**

With source window active, press `Ctrl+Shift+T`. Expected: receiver proposes trade → source window accepts → tooltip "Aceito!". If accept button not detected within 5 s: tooltip "Erro: proposta de troca não detectada (timeout 5s)".

- [ ] **Step 5: Remove smoke test**

```ahk
run() {
}
```

- [ ] **Step 6: Commit**

```bash
git add src/clients/trade.ahk config.json
git commit -m "feat: implement TradeManager._acceptTrade() and fill acceptButton config"
```

---

### Task 8: Implement `_confirmTrade(sourceName, receiverName)` and fill confirmButton config

**Files:**
- Modify: `src/clients/trade.ahk`
- Modify: `config.json`

- [ ] **Step 1: Fill in `confirmButton` in config.json**

In-game, open a trade window (both sides) and locate the confirm button:

1. Run `copy_pixel_color_and_position.ahk` — hover over the confirm button, note `[X, Y]` and pixel color
2. Update `config.json`:
   ```json
   "confirmButton": {
       "click": [X, Y],
       "detect": { "pos": [X, Y], "color": "0xRRGGBB" }
   }
   ```

> The confirm button is at the same screen position in both source and receiver trade windows (same trade UI layout).

- [ ] **Step 2: Implement `_confirmTrade(sourceName, receiverName)`**

```ahk
_confirmTrade(sourceName, receiverName) {
    confirmClick  := this.tradeConfig["confirmButton"]["click"]
    confirmDetect := this.tradeConfig["confirmButton"]["detect"]

    this.account.focus(sourceName)
    this.client.sleep()
    if (!this.client.waitForPixelDetect(confirmDetect, 5000)) {
        this._tip("Erro: botão confirmar não detectado (fonte)")
        return
    }
    Click(confirmClick[1], confirmClick[2])
    this.client.sleep()

    this.account.focus(receiverName)
    this.client.sleep()
    if (!this.client.waitForPixelDetect(confirmDetect, 5000)) {
        this._tip("Erro: botão confirmar não detectado (receptor)")
        return
    }
    Click(confirmClick[1], confirmClick[2])
    this.client.sleep()
}
```

- [ ] **Step 3: Add smoke test in `run()`**

```ahk
run() {
    sourceId     := WinExist("A")
    sourceName   := this.account.getAccountByWindow(sourceId)
    openAccounts := this.account.getOpenAccounts()

    for accountName in openAccounts {
        if (accountName = sourceName)
            continue
        this._proposeTrade(accountName)
        if (!this._acceptTrade(sourceName))
            return
        if (!this._waitUserAddItems())
            return
        this._confirmTrade(sourceName, accountName)
        this._tip("Troca completa!")
        break
    }
}
```

- [ ] **Step 4: Launch and test**

With source window active, press `Ctrl+Shift+T`. Expected: full single-trade flow — propose → accept → GUI (add items + Confirmar) → both windows confirm → tooltip "Troca completa!".

- [ ] **Step 5: Remove smoke test**

```ahk
run() {
}
```

- [ ] **Step 6: Commit**

```bash
git add src/clients/trade.ahk config.json
git commit -m "feat: implement TradeManager._confirmTrade() and fill confirmButton config"
```

---

### Task 9: Implement `run()` — full multi-account loop

**Files:**
- Modify: `src/clients/trade.ahk`

- [ ] **Step 1: Implement `run()`**

```ahk
run() {
    sourceId   := WinExist("A")
    sourceName := this.account.getAccountByWindow(sourceId)

    if (sourceName = "") {
        this._tip("Erro: janela ativa não é uma conta conhecida")
        return
    }

    openAccounts := this.account.getOpenAccounts()
    receivers := []
    for accountName in openAccounts {
        if (accountName != sourceName)
            receivers.Push(accountName)
    }

    if (receivers.Length = 0) {
        this._tip("Nenhuma conta receptora aberta")
        return
    }

    for receiverName in receivers {
        this._proposeTrade(receiverName)

        if (!this._acceptTrade(sourceName)) {
            this.account.focus(sourceName)
            return
        }

        if (!this._waitUserAddItems()) {
            this.account.focus(sourceName)
            return
        }

        this._confirmTrade(sourceName, receiverName)
    }

    this.account.focus(sourceName)
    this._tip("Trocas concluídas")
}
```

- [ ] **Step 2: Launch and test — full multi-account flow**

With all accounts open and source window active, press `Ctrl+Shift+T`. Verify:

1. **Happy path:** iterates each receiver → propose → accept → add items → Confirmar → confirm both → repeats → "Trocas concluídas" tooltip → focus returns to source
2. **Cancel mid-loop:** when GUI appears, click Cancelar → loop aborts → focus returns to source
3. **No receivers:** activate sole open account, press hotkey → tooltip "Nenhuma conta receptora aberta"
4. **Unknown window:** press hotkey with a non-Dofus window active → tooltip "Erro: janela ativa não é uma conta conhecida"

- [ ] **Step 3: Commit**

```bash
git add src/clients/trade.ahk
git commit -m "feat: implement TradeManager.run() multi-account loop"
```
