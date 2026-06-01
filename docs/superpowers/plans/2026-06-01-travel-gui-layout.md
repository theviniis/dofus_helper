# Travel Gui Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reformatar o diálogo de travel com dois GroupBoxes ("Destino" e "Opções"), campo Edit sem borda recessed (-E0x200), e botões OK/Cancelar lado a lado no canto direito.

**Architecture:** Substituição completa do bloco de construção do `Gui` em `TravelNavigator.use()`. Apenas o layout muda — lógica de submit, validação, foco e envio do `/travel` permanecem intactos.

**Tech Stack:** AutoHotkey v2.0 — sem dependências externas, sem framework de testes. Verificação é visual (rodar o script no Windows).

---

### Task 1: Reformatar o Gui em `travel.ahk`

**Files:**
- Modify: `src/clients/travel.ahk`

- [ ] **Step 1: Ler o arquivo atual**

Abrir `/home/viniis/dofus/src/clients/travel.ahk` e confirmar que o bloco Gui atual é:

```ahk
g := Gui(, "Coordenadas")
g.Add("Text",, "Coordenadas (xx,yy):")
g.Add("Edit", "w200 vCoords")
g.Add("CheckBox", "vFocusMain Checked", "Focar personagem principal?")
g.Add("Button", "Default w80", "OK").OnEvent("Click", OkClick)
g.Add("Button", "w80", "Cancelar").OnEvent("Click", (*) => g.Destroy())
g.OnEvent("Close", (*) => g.Destroy())

g.Show()
```

- [ ] **Step 2: Substituir o bloco Gui pelo novo layout**

Substituir exatamente o bloco acima (da linha `g := Gui(...)` até `g.Show()`) pela versão abaixo:

```ahk
g := Gui(, "Coordenadas")
g.Add("GroupBox", "x10 y10 w240 h65", "Destino")
g.Add("Text", "x20 y28", "Coordenadas (xx,yy):")
g.Add("Edit", "x20 y44 w220 vCoords -E0x200")
g.Add("GroupBox", "x10 y82 w240 h40", "Opções")
g.Add("CheckBox", "x20 y97 vFocusMain Checked", "Focar personagem principal?")
g.Add("Button", "x80 y132 w80", "Cancelar").OnEvent("Click", (*) => g.Destroy())
g.Add("Button", "x170 y132 w80 Default", "OK").OnEvent("Click", OkClick)
g.OnEvent("Close", (*) => g.Destroy())

g.Show("w260")
```

**Notas de posicionamento:**
- GUI width fixa em 260px via `g.Show("w260")`
- GroupBox "Destino": x=10, y=10, w=240, h=65
  - Text: y=28 (18px abaixo do topo do GroupBox, abaixo da linha de título)
  - Edit: y=44 (16px abaixo do Text)
- GroupBox "Opções": x=10, y=82 (5px abaixo do fim de "Destino" em y=75), h=40
  - CheckBox: y=97 (15px abaixo do topo do GroupBox)
- Botões: y=132 (10px abaixo do fim de "Opções" em y=122)
  - Cancelar: x=80, w=80
  - OK: x=170, w=80, Default
- `-E0x200` remove `WS_EX_CLIENTEDGE` (borda 3D recessed) do Edit

- [ ] **Step 3: Verificar que o restante do método não foi alterado**

Confirmar que estas linhas permanecem idênticas após o bloco Gui:

```ahk
WinWaitClose(g)

if !submitted
    return false

if (Trim(savedData.Coords) = "")
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
```

- [ ] **Step 4: Commit**

```bash
git add src/clients/travel.ahk
git commit -m "feat: add GroupBox layout and right-aligned buttons to travel dialog"
```

---

### Task 2: Verificação visual no Windows

**Pré-requisito:** Ter o script rodando (`index.ahk` ativo).

- [ ] **Step 1: Pressionar `Ctrl+T`**

Confirmar que o diálogo abre com:
- GroupBox "Destino" visível com label e campo de texto sem borda 3D
- GroupBox "Opções" visível com checkbox marcado
- Botões "Cancelar" e "OK" lado a lado no canto direito

- [ ] **Step 2: Confirmar fluxo de submit**

Digitar coordenadas válidas (ex: `5,-18`) e clicar OK. Confirmar que o `/travel 5,-18` é enviado normalmente.

- [ ] **Step 3: Confirmar cancelamento**

Pressionar `Ctrl+T`, clicar Cancelar. Confirmar que nenhum comando é enviado.
