# ClientInterface Abstraction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Isolar toda a lógica de interação com janela/jogo (WinActivate, Send, Click, PixelGetColor) no ClientInterface, criando uma abstração que outros módulos utilizam via injeção de dependência.

**Architecture:** Aplicar Dependency Inversion - dependências (ClientInterface) são injetadas nos módulos que as utilizam (AccountManager, ZapNavigator). Cada arquivo tem uma única responsabilidade clara.

**Tech Stack:** AutoHotkey v2.0

---

## Task 1: Expandir ClientInterface com métodos de interação

**Files:**
- Modify: `src/utils/client_interface.ahk`

### Step 1: Sobrescrever client_interface.ahk com nova implementação

```autohotkey
#Requires AutoHotkey v2.0

class ClientInterface {
    __New(config) {
        this.config := config
        this.sleepTime := 200
    }

    focusWindow(windowName?) {
        if (windowName = "") {
            WinActivate("ahk_exe Dofus.exe")
        } else {
            WinActivate(windowName)
        }
    }

    waitWindow(windowName) {
        WinWait(windowName)
    }

    windowExists(windowName) {
        return WinExist(windowName)
    }

    sendText(text) {
        Send(text)
    }

    sendKey(key) {
        Send(key)
    }

    openChat() {
        this.focusWindow()
        Sleep(this.sleepTime)
        Send(" ")
    }

    confirm() {
        Send("{Enter}")
    }

    clickAt(coordName) {
        coord := this.config.sacoDeViagens[coordName]
        Click(coord.click[1], coord.click[2])
    }

    pixelMatches(coordName) {
        detect := this.config.sacoDeViagens[coordName].detect
        pixelColor := PixelGetColor(detect.pos[1], detect.pos[2])
        return pixelColor == detect.color
    }

    sleep(ms?) {
        if (ms = "") {
            ms := this.sleepTime
        }
        Sleep(ms)
    }
}
```

### Step 2: Commit

```bash
git add src/utils/client_interface.ahk
git commit -m "feat(client_interface): adiciona métodos de interação com janela/jogo"
```

---

## Task 2: Atualizar AccountManager para usar ClientInterface via DI

**Files:**
- Modify: `src/utils/accounts.ahk`

### Step 1: Reescrever accounts.ahk com dependência injetada

```autohotkey
#Requires AutoHotkey v2.0

class AccountManager {
    __New(accountList, clientIF) {
        this.accountList := accountList
        this.clientIF := clientIF
    }

    focus(accountName) {
        windowName := this.accountList.Get(accountName)
        this.clientIF.waitWindow(windowName)
        this.clientIF.focusWindow(windowName)
    }

    getOpenAccounts() {
        openAccounts := []
        for accountName, windowName in this.accountList {
            if this.clientIF.windowExists(windowName) {
                openAccounts.Push(accountName)
            }
        }
        return openAccounts
    }

    getAccountByWindow(windowId) {
        for accountName, windowName in this.accountList {
            if WinExist(windowName) = windowId {
                return accountName
            }
        }
        return ""
    }
}
```

### Step 2: Commit

```bash
git add src/utils/accounts.ahk
git commit -m "refactor(accounts): injeta ClientInterface via construtor"
```

---

## Task 3: Atualizar ZapNavigator para usar ClientInterface via DI

**Files:**
- Modify: `src/utils/use_zap.ahk`
- Remove: `src/utils/does_pixel_matches.ahk`

### Step 1: Reescrever use_zap.ahk com dependência injetada

```autohotkey
#Requires AutoHotkey v2.0

class ZapNavigator {
    __New(travelersBagConfig, clientIF) {
        this.travelersBagConfig := travelersBagConfig
        this.clientIF := clientIF
        this.running := false
        this.destination := ""
    }

    isOnTravelScreen {
        get {
            return this.clientIF.pixelMatches("zap")
        }
    }

    isZapInterfaceOpen {
        get {
            return this.clientIF.pixelMatches("interfaceZap")
        }
    }

    clickZap() {
        this.clientIF.clickAt("zap")
    }

    clickSearch() {
        this.clientIF.clickAt("search")
    }

    travel() {
        this.clientIF.sendKey("h")
    }

    use(forceInput := true) {
        if (this.destination = "" || forceInput) {
            destination := InputBox(
                "Para onde deseja viajar?",
                "Destino",
            )
            if (destination.result != "OK" or destination.value = "") {
                return false
            }
            this.destination := destination.value
        }

        this.running := true

        while (this.running) {
            isZapOpen := this.isZapInterfaceOpen
            isTravelOpen := this.isOnTravelScreen

            if (isZapOpen) {
                this.clickSearch()
                this.clientIF.sleep()
                this.clientIF.sendText(this.destination)
                this.clientIF.sleep()
                this.clientIF.confirm()
                break
            }
            else if (isTravelOpen) {
                this.clickZap()
            }
            else {
                this.travel()
            }

            this.clientIF.sleep()
        }

        this.running := false
        return true
    }

    stop() {
        this.running := false
    }
}
```

### Step 2: Remover does_pixel_matches.ahk

```bash
rm src/utils/does_pixel_matches.ahk
```

### Step 3: Commit

```bash
git add src/utils/use_zap.ahk
git rm src/utils/does_pixel_matches.ahk
git commit -m "refactor(use_zap): injeta ClientInterface, Remove does_pixel_matches"
```

---

## Task 4: Atualizar index.ahk para injeção de dependências

**Files:**
- Modify: `index.ahk`

### Step 1: Atualizar index.ahk

```autohotkey
#SingleInstance Force
#Requires AutoHotkey v2.0
#HotIf WinActive("ahk_exe Dofus.exe")
#Include ./src/utils/use_zap.ahk
#Include ./src/utils/accounts.ahk
#Include ./src/utils/zap_coordinator.ahk
#Include ./src/utils/copy_window_name.ahk
#Include ./src/utils/client_interface.ahk
#Include ./src/utils/travel.ahk

SetTitleMatchMode 3
SendMode "Input"
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")

config := {
    accountList: Map(
        'iop', 'Bate-no-sigilo - Iop - 3.5.14.18 - Release',
        'eni', 'Cura-no-sigilo - Eniripsa - 3.5.14.18 - Release',
        'sac', 'Berserker-no-sigilo - Sacrier - 3.5.14.18 - Release',
    ),
    sacoDeViagens: {
        zap: {
            click: [1165, 554],
            detect: {
                pos: [1445, 429],
                color: 0xA75F20
            }
        },
        interfaceZap: {
            detect: {
                pos: [1595, 410],
                color: 0x173238
            }
        },
        search: {  ; renamed from barraBusca
            click: [1334, 515]
        }
    }
}

clientIF := ClientInterface(config)
acc := AccountManager(config.accountList, clientIF)
zapNav := ZapNavigator(config.sacoDeViagens, clientIF)
travelNav := TravelNavigator(clientIF)
coordinator := ZapCoordinator(zapNav, acc)

$#1:: acc.focus('iop')
$#2:: acc.focus('eni')
$#3:: acc.focus('sac')
$t:: travelNav.use()

$h:: zapNav.use()
$+h:: coordinator.runAll()
$^Esc:: zapNav.stop()

$#c:: copyWindowName()
```

### Step 2: Commit

```bash
git add index.ahk
git commit -m "refactor(index): injeta dependências em AccountManager e ZapNavigator"
```

---

## Execution

**Plan complete and saved to `docs/superpowers/plans/2026-05-10-client-interface-abstraction-plan.md`. Two execution options:**

1. **Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

2. **Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**