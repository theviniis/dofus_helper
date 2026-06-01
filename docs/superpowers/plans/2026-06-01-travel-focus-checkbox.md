# Travel Focus Checkbox Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar checkbox "Focar personagem principal?" ao diálogo de travel, que foca a janela do personagem principal antes de enviar `/travel` quando marcado (default: true).

**Architecture:** Substituir `InputBox` por `Gui` AHK v2 customizado em `TravelNavigator`. O construtor passa a receber `account` (AccountManager) e `mainCharacter` (string). `Init` recebe `mainCharacter` como parâmetro e repassa para `TravelNavigator`. `index.ahk` passa `MAIN_CHARACTER` para `Init` e remove o `account.focus` explícito do hotkey.

**Tech Stack:** AutoHotkey v2.0 — sem dependências externas, sem framework de testes. Verificação é manual (rodar o script no Windows com Dofus aberto).

---

### Task 1: Atualizar `init.ahk` para receber e repassar `mainCharacter`

**Files:**
- Modify: `src/utils/init.ahk`

- [ ] **Step 1: Abrir o arquivo atual**

Conteúdo atual de `src/utils/init.ahk` (linhas 9-17):
```ahk
class Init {
    __New(config) {
        this.client    := ClientInterface(config)
        this.account   := AccountManager(config["accounts"], this.client)
        this.zap       := ZapNavigator(config["travelersBag"], this.client, TravelHistory(), this.account)
        this.travel    := TravelNavigator(this.client)
        this.macro     := MacroBroadcaster(this.account, this.client)
    }
}
```

- [ ] **Step 2: Aplicar a mudança**

Substituir o conteúdo de `src/utils/init.ahk` pela versão abaixo:

```ahk
#Requires AutoHotkey v2.0
#Include ../clients/client.ahk
#Include ../clients/travel_history.ahk
#Include ../clients/zap.ahk
#Include ../clients/account.ahk
#Include ../clients/travel.ahk
#Include ../clients/macro_broadcaster.ahk

class Init {
    __New(config, mainCharacter) {
        this.client    := ClientInterface(config)
        this.account   := AccountManager(config["accounts"], this.client)
        this.zap       := ZapNavigator(config["travelersBag"], this.client, TravelHistory(), this.account)
        this.travel    := TravelNavigator(this.client, this.account, mainCharacter)
        this.macro     := MacroBroadcaster(this.account, this.client)
    }
}
```

- [ ] **Step 3: Verificar sintaticamente**

Abrir `src/utils/init.ahk` e confirmar que:
- `__New(config, mainCharacter)` tem dois parâmetros
- `TravelNavigator(this.client, this.account, mainCharacter)` tem três argumentos
- Nenhuma outra linha foi alterada

- [ ] **Step 4: Commit**

```bash
git add src/utils/init.ahk
git commit -m "feat: pass mainCharacter to Init and TravelNavigator"
```

---

### Task 2: Substituir `InputBox` por `Gui` com checkbox em `travel.ahk`

**Files:**
- Modify: `src/clients/travel.ahk`

- [ ] **Step 1: Substituir o conteúdo completo de `src/clients/travel.ahk`**

```ahk
#Requires AutoHotkey v2.0

SLEEP_TIME := 200

class TravelNavigator {
    __New(client, account, mainCharacter) {
        this.client := client
        this.account := account
        this.mainCharacter := mainCharacter
    }

    use() {
        submitted := false
        savedData := ""

        OkClick(*) {
            savedData := g.Submit()
            submitted := true
            g.Destroy()
        }

        g := Gui(, "Coordenadas")
        g.Add("Text",, "Coordenadas (xx,yy):")
        g.Add("Edit", "w200 vCoords")
        g.Add("CheckBox", "vFocusMain Checked", "Focar personagem principal?")
        g.Add("Button", "Default w80", "OK").OnEvent("Click", OkClick)
        g.Add("Button", "w80", "Cancelar").OnEvent("Click", (*) => g.Destroy())
        g.OnEvent("Close", (*) => g.Destroy())

        g.Show()
        WinWaitClose(g)

        if !submitted
            return false

        if !RegExMatch(Trim(savedData.Coords), "i)^(?:/travel\s*)?\[?\s*(-?\d+\s*,\s*-?\d+)\s*\]?[.,]?$", &m) {
            ToolTip("Formato inválido. Use xx,yy")
            Sleep(1500)
            ToolTip("")
            return false
        }

        if savedData.FocusMain
            this.account.focus(this.mainCharacter)

        this.client.openChat()
        Sleep(SLEEP_TIME)
        destination := "/travel " . RegExReplace(m[1], "\s", "")
        this.client.clearInput()
        this.client.sendText(destination)
        Sleep(SLEEP_TIME)
        this.client.confirm()
        this.client.sleep(1000)
        this.client.sendKey("{Esc}")
        return true
    }
}
```

**Notas de implementação:**
- `g.Submit()` retorna um objeto com os valores dos controles nomeados: `savedData.Coords` (Edit) e `savedData.FocusMain` (`1` ou `0` para o CheckBox)
- `"Checked"` no `Add("CheckBox", ...)` garante que o checkbox começa marcado
- A nested function `OkClick` é definida antes de `g` para compatibilidade com AHK v2, mas acessa `g`, `savedData` e `submitted` por referência ao escopo externo no momento da chamada (não da definição)
- `WinWaitClose(g)` bloqueia até o Gui ser destruído, tornando o diálogo modal

- [ ] **Step 2: Verificar a lógica do checkbox**

Checar que:
- `"vFocusMain Checked"` está presente na linha do `CheckBox`
- `if savedData.FocusMain` precede `this.account.focus(this.mainCharacter)` e vem **antes** de `openChat()`
- O bloco de validação de regex usa `savedData.Coords` (não `input.value`)

- [ ] **Step 3: Commit**

```bash
git add src/clients/travel.ahk
git commit -m "feat: replace InputBox with Gui dialog, add focus checkbox to TravelNavigator"
```

---

### Task 3: Atualizar `index.ahk`

**Files:**
- Modify: `index.ahk`

- [ ] **Step 1: Passar `MAIN_CHARACTER` para `Init`**

Localizar a linha:
```ahk
app := Init(config)
```

Substituir por:
```ahk
app := Init(config, MAIN_CHARACTER)
```

- [ ] **Step 2: Remover `account.focus` explícito do hotkey `$^t`**

Localizar o bloco:
```ahk
$^t:: {
    app.account.focus(MAIN_CHARACTER)
    app.travel.use()
}
```

Substituir por:
```ahk
$^t:: app.travel.use()
```

O foco agora é controlado pelo checkbox dentro de `TravelNavigator.use()`.

- [ ] **Step 3: Verificar o arquivo**

Confirmar que:
- `MAIN_CHARACTER` ainda está declarado acima de `Init` (linha `MAIN_CHARACTER := 'enu'`)
- `app := Init(config, MAIN_CHARACTER)` tem dois argumentos
- O hotkey `$^t` não contém mais referência a `account.focus`
- Nenhum outro hotkey foi alterado

- [ ] **Step 4: Commit**

```bash
git add index.ahk
git commit -m "feat: wire MAIN_CHARACTER into Init, remove explicit focus from travel hotkey"
```

---

### Task 4: Verificação manual no Windows

**Pré-requisito:** Ter o Dofus aberto com ao menos uma conta visível.

- [ ] **Step 1: Rodar o script**

Dar duplo-clique em `index.ahk` (ou reiniciar se já estiver rodando).

- [ ] **Step 2: Testar fluxo normal com checkbox marcado (default)**

1. Pressionar `Ctrl+T`
2. Confirmar que o `Gui` abre com campo de texto e checkbox "Focar personagem principal?" **marcado**
3. Digitar coordenadas válidas (ex: `5,-18`)
4. Clicar OK
5. Confirmar que a janela do personagem principal ganhou foco
6. Confirmar que o comando `/travel 5,-18` foi enviado no chat

- [ ] **Step 3: Testar com checkbox desmarcado**

1. Pressionar `Ctrl+T` de uma janela de conta secundária
2. Desmarcar o checkbox
3. Digitar coordenadas válidas (ex: `0,0`)
4. Clicar OK
5. Confirmar que a janela da conta secundária **não perdeu foco**
6. Confirmar que o `/travel 0,0` foi enviado para essa conta

- [ ] **Step 4: Testar cancelamento**

1. Pressionar `Ctrl+T`
2. Clicar Cancelar (ou fechar a janela com X)
3. Confirmar que nenhum comando foi enviado e nenhuma janela foi focada

- [ ] **Step 5: Testar formato inválido**

1. Pressionar `Ctrl+T`
2. Digitar `abc` no campo de coordenadas e clicar OK
3. Confirmar que o `ToolTip("Formato inválido. Use xx,yy")` aparece por ~1.5s
