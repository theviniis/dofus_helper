# Chat Travel via `/travel` Implementation Plan

**Goal:** Ao pressionar `t`, exibir InputBox para coordenadas `xx,yy`, abrir chat do Dofus, enviar `/travel xx,yy`.

**Architecture:** Nova classe `ClientInterface` para interação com UI do cliente; nova classe `TravelNavigator` para validação e orquestração. Segue DIP — `TravelNavigator` recebe `ClientInterface` via construtor.

**Tech Stack:** AutoHotkey v2.0

---

### Task 1: Criar `ClientInterface`

**Files:**
- Create: `src/utils/client_interface.ahk`

```autohotkey
#Requires AutoHotkey v2.0

class ClientInterface {
    focusWindow() {
        WinActivate("ahk_exe Dofus.exe")
    }

    openChat() {
        this.focusWindow()
        Sleep(200)
        Send(" ")
    }

    sendText(text) {
        Send(text)
    }

    confirm() {
        Send("{Enter}")
    }
}
```

- [ ] **Step 1: Criar arquivo com código acima**

- [ ] **Step 2: Commit**

```bash
git add src/utils/client_interface.ahk
git commit -m "feat: add ClientInterface for Dofus UI interaction"
```

---

### Task 2: Criar `TravelNavigator`

**Files:**
- Create: `src/utils/travel.ahk`

```autohotkey
#Requires AutoHotkey v2.0

SLEEP_TIME := 200

class TravelNavigator {
    __New(clientInterface) {
        this.clientIF := clientInterface
    }

    use() {
        input := InputBox(
            "xx,yy",
            "Coordenadas",
        )
        if (input.result != "OK" or input.value = "") {
            return false
        }

        if !RegExMatch(input.value, "^\d+,\d+$") {
            ToolTip("Formato inválido. Use xx,yy")
            Sleep(1500)
            ToolTip("")
            return false
        }

        this.clientIF.openChat()
        Sleep(SLEEP_TIME)
        this.clientIF.sendText("/travel " . input.value)
        Sleep(SLEEP_TIME)
        this.clientIF.confirm()
        return true
    }
}
```

- [ ] **Step 1: Criar arquivo com código acima**

- [ ] **Step 2: Commit**

```bash
git add src/utils/travel.ahk
git commit -m "feat: add TravelNavigator with coordinate validation"
```

---

### Task 3: Integrar em `index.ahk`

**Files:**
- Modify: `index.ahk:1-52`

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
        barraBusca: {
            click: [1334, 515]
        }
    }
}

acc := AccountManager(config.accountList)
clientIF := ClientInterface()
zapNav := ZapNavigator(config.sacoDeViagens)
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

- [ ] **Step 1: Adicionar `#Include` de `client_interface.ahk` e `travel.ahk` (após copy_window_name)**

- [ ] **Step 2: Adicionar `clientIF := ClientInterface()` após `acc`**

- [ ] **Step 3: Adicionar `travelNav := TravelNavigator(clientIF)` após `zapNav`**

- [ ] **Step 4: Adicionar hotkey `$t:: travelNav.use()` (após `$#3`)**

- [ ] **Step 5: Commit**

```bash
git add index.ahk
git commit -m "feat: integrate TravelNavigator on hotkey t"
```

---

**Spec coverage:** client_interface.ahk, travel.ahk, index.ahk integration, hotkey `t`, regex validation. Tudo coberto.

**Type consistency:** `ClientInterface` com métodos `focusWindow`, `openChat`, `sendText`, `confirm`. `TravelNavigator` recebe `clientInterface` via construtor e chama `openChat`, `sendText`, `confirm`. Nomes consistentes entre tasks.

**Placeholder scan:** Nenhum TBD/TODO encontrado. Código completo em todos os steps.
