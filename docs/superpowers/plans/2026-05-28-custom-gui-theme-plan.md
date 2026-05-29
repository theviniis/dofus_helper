# Custom GUI Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Criar um módulo `GuiTheme` centralizado que aplica paleta dark fantasy/âmbar em todos os GUIs do projeto via `OnMessage` Win32.

**Architecture:** A classe `GuiTheme` em `src/utils/gui_theme.ahk` expõe dois métodos públicos: `Apply(gui)` configura fundo e fonte da janela e registra handlers `WM_CTLCOLOR*` globais; `_OnCtlColor` intercepta renderização de botões, checkboxes, edits e listboxes para pintar com as cores do tema. Os GUIs existentes recebem uma chamada `GuiTheme.Apply(myGui)` logo após a criação e o `InputBox` do TravelNavigator é substituído por um `Gui` próprio com o mesmo tema.

**Tech Stack:** AutoHotkey v2.0, Win32 GDI (CreateSolidBrush, SetTextColor, SetBkColor via DllCall), OnMessage API do AHK v2.

---

## Mapa de Arquivos

| Arquivo | Ação | Responsabilidade |
|---|---|---|
| `src/utils/gui_theme.ahk` | Criar | Classe GuiTheme com paleta, Apply() e _OnCtlColor() |
| `src/utils/header.ahk` | Modificar | Adicionar `#Include ./gui_theme.ahk` |
| `src/clients/zap.ahk` | Modificar | Aplicar GuiTheme.Apply() em getDestination() |
| `src/clients/travel.ahk` | Modificar | Substituir InputBox por Gui temático |

---

## Task 1: Criar `src/utils/gui_theme.ahk`

**Files:**
- Create: `src/utils/gui_theme.ahk`

> **Contexto:** AHK v2 não suporta `BackColor` em botões e checkboxes. A solução é interceptar as mensagens Win32 `WM_CTLCOLOR*` via `OnMessage`. Quando o Windows renderiza um controle, envia uma dessas mensagens à janela pai com `wParam = HDC` do controle. O handler configura cores no HDC e retorna um brush GDI. Cores no AHK são `0xRRGGBB`; Win32 `COLORREF` é `0x00BBGGRR` — é preciso converter. Brushes são criados uma vez e cacheados para evitar leak.

- [ ] **Step 1: Criar o arquivo com a classe GuiTheme**

Criar `src/utils/gui_theme.ahk` com o conteúdo completo:

```ahk
#Requires AutoHotkey v2.0

class GuiTheme {
    ; Paleta dark fantasy / âmbar
    static BG_DARK    := 0x1A1510
    static BG_CONTROL := 0x2B2218
    static FG_TEXT    := 0xE8D5A3
    static FG_DIM     := 0x8A7355
    static ACCENT     := 0xC89B3C
    static BG_BUTTON  := 0x3D2E1A
    static FONT_NAME  := "Segoe UI"
    static FONT_SIZE  := 10

    ; Estado interno
    static _registered := false
    static _darkBrush  := 0
    static _ctrlBrush  := 0
    static _btnBrush   := 0

    ; Aplica tema na janela: fundo, fonte e registra WM_CTLCOLOR* (uma única vez)
    static Apply(gui) {
        gui.BackColor := Format("{:06X}", GuiTheme.BG_DARK)
        gui.SetFont(
            "s" GuiTheme.FONT_SIZE " c" Format("{:06X}", GuiTheme.FG_TEXT),
            GuiTheme.FONT_NAME
        )
        if (!GuiTheme._registered) {
            OnMessage(0x0133, GuiTheme._OnCtlColor)  ; WM_CTLCOLOREDIT
            OnMessage(0x0134, GuiTheme._OnCtlColor)  ; WM_CTLCOLORLISTBOX
            OnMessage(0x0135, GuiTheme._OnCtlColor)  ; WM_CTLCOLORBTN
            OnMessage(0x0138, GuiTheme._OnCtlColor)  ; WM_CTLCOLORSTATIC
            GuiTheme._registered := true
        }
    }

    ; Converte 0xRRGGBB (AHK) para 0x00BBGGRR (Win32 COLORREF)
    static _ToCOLORREF(rgb) {
        r := (rgb >> 16) & 0xFF
        g := (rgb >> 8) & 0xFF
        b := rgb & 0xFF
        return (b << 16) | (g << 8) | r
    }

    static _GetDarkBrush() {
        if (!GuiTheme._darkBrush)
            GuiTheme._darkBrush := DllCall("gdi32\CreateSolidBrush",
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_DARK), "Ptr")
        return GuiTheme._darkBrush
    }

    static _GetCtrlBrush() {
        if (!GuiTheme._ctrlBrush)
            GuiTheme._ctrlBrush := DllCall("gdi32\CreateSolidBrush",
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_CONTROL), "Ptr")
        return GuiTheme._ctrlBrush
    }

    static _GetBtnBrush() {
        if (!GuiTheme._btnBrush)
            GuiTheme._btnBrush := DllCall("gdi32\CreateSolidBrush",
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_BUTTON), "Ptr")
        return GuiTheme._btnBrush
    }

    ; Handler Win32: chamado pelo Windows ao renderizar cada controle
    static _OnCtlColor(wParam, lParam, msg, hwnd) {
        hdc := wParam

        if (msg = 0x0133 || msg = 0x0134) {  ; Edit ou ListBox
            DllCall("gdi32\SetTextColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.FG_TEXT))
            DllCall("gdi32\SetBkColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_CONTROL))
            return GuiTheme._GetCtrlBrush()
        }

        if (msg = 0x0135) {  ; Button
            DllCall("gdi32\SetTextColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.FG_TEXT))
            DllCall("gdi32\SetBkColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_BUTTON))
            return GuiTheme._GetBtnBrush()
        }

        if (msg = 0x0138) {  ; CheckBox, GroupBox, Text (Static)
            isEnabled := DllCall("user32\IsWindowEnabled", "Ptr", lParam, "Int")
            textColor := isEnabled ? GuiTheme.FG_TEXT : GuiTheme.FG_DIM
            DllCall("gdi32\SetTextColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(textColor))
            DllCall("gdi32\SetBkColor", "Ptr", hdc,
                "UInt", GuiTheme._ToCOLORREF(GuiTheme.BG_DARK))
            return GuiTheme._GetDarkBrush()
        }
    }
}
```

- [ ] **Step 2: Verificar que o arquivo foi criado sem erros de sintaxe**

Criar `_test_theme.ahk` temporário na raiz do projeto:

```ahk
#Requires AutoHotkey v2.0
#Include ./src/utils/header.ahk
#Include ./src/utils/gui_theme.ahk

myGui := Gui("+AlwaysOnTop", "Teste Tema")
GuiTheme.Apply(myGui)
myGui.Add("Text", "x10 y10 w200", "Texto normal")
myGui.Add("Edit", "x10 y30 w200", "Edit temático")
myGui.Add("CheckBox", "x10 y60", "Checkbox ativo")
myGui.Add("CheckBox", "x10 y85 Disabled", "Checkbox desabilitado")
myGui.Add("Button", "x10 y110 w80", "Cancel")
okBtn := myGui.Add("Button", "x+10 y110 w80 Default", "OK")
okBtn.SetFont("bold c" Format("{:06X}", GuiTheme.ACCENT))
myGui.Show()
```

Rodar `_test_theme.ahk` com AHK v2. Resultado esperado: janela aparece com fundo escuro `#1A1510`, texto âmbar `#E8D5A3`, Edit com fundo `#2B2218`, botão OK em negrito dourado `#C89B3C`, checkbox desabilitado em `#8A7355`.

- [ ] **Step 3: Apagar `_test_theme.ahk` após verificação**

```bash
rm _test_theme.ahk
```

- [ ] **Step 4: Commit**

```bash
git add src/utils/gui_theme.ahk
git commit -m "feat: add GuiTheme module with dark fantasy palette"
```

---

## Task 2: Incluir `gui_theme.ahk` globalmente via `header.ahk`

**Files:**
- Modify: `src/utils/header.ahk`

> **Contexto:** `header.ahk` é o primeiro `#Include` carregado por `index.ahk`. Adicionar `gui_theme.ahk` aqui garante que `GuiTheme` esteja disponível em todos os arquivos sem include extra por arquivo.

- [ ] **Step 1: Adicionar include ao final de `header.ahk`**

Arquivo atual (`src/utils/header.ahk`):
```ahk
#Requires AutoHotkey v2.0

#SingleInstance Force
SetTitleMatchMode 3
SendMode "Input"
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")

DOFUS_CLIENT := "ahk_exe Dofus.exe"
SLEEP_TIME := 250

; #HotIf WinActive(DOFUS_CLIENT)
```

Adicionar ao final:
```ahk
#Include ./gui_theme.ahk
```

Resultado final de `src/utils/header.ahk`:
```ahk
#Requires AutoHotkey v2.0

#SingleInstance Force
SetTitleMatchMode 3
SendMode "Input"
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")

DOFUS_CLIENT := "ahk_exe Dofus.exe"
SLEEP_TIME := 250

; #HotIf WinActive(DOFUS_CLIENT)

#Include ./gui_theme.ahk
```

- [ ] **Step 2: Rodar `index.ahk` e verificar que carrega sem erros**

Rodar `index.ahk` com AHK v2. Resultado esperado: script inicia normalmente, nenhuma caixa de erro de include ou syntax. Testar `Win+1` para focar uma conta — deve funcionar normalmente.

- [ ] **Step 3: Commit**

```bash
git add src/utils/header.ahk
git commit -m "feat: include GuiTheme globally via header.ahk"
```

---

## Task 3: Aplicar tema em `ZapNavigator.getDestination()`

**Files:**
- Modify: `src/clients/zap.ahk:53-131`

> **Contexto:** A função `getDestination()` cria um `Gui` com GroupBox Destino (ListBox + Edit) e opcionalmente GroupBox Contas (Checkboxes). Precisamos: (1) chamar `GuiTheme.Apply(myGui)` logo após a criação, (2) remover a chamada `myGui.SetFont("s10")` redundante, (3) aplicar negrito ACCENT no botão OK.

- [ ] **Step 1: Substituir a criação do Gui e SetFont em `getDestination()`**

Localizar em `src/clients/zap.ahk` (linhas 53-54):
```ahk
        myGui := Gui("+AlwaysOnTop", "ZapNavigator - Destino")
        myGui.SetFont("s10")
```

Substituir por:
```ahk
        myGui := Gui("+AlwaysOnTop", "ZapNavigator - Destino")
        GuiTheme.Apply(myGui)
```

- [ ] **Step 2: Aplicar ACCENT no botão OK**

Localizar em `src/clients/zap.ahk` (linhas 127-128):
```ahk
        myGui.Add("Button", "x" gbX " y" btnY " w80", "Cancel").OnEvent("Click", OnCancel)
        myGui.Add("Button", "x+10 y" btnY " w80 Default", "OK").OnEvent("Click", OnOK)
```

Substituir por:
```ahk
        myGui.Add("Button", "x" gbX " y" btnY " w80", "Cancel").OnEvent("Click", OnCancel)
        okBtn := myGui.Add("Button", "x+10 y" btnY " w80 Default", "OK")
        okBtn.SetFont("bold c" Format("{:06X}", GuiTheme.ACCENT))
        okBtn.OnEvent("Click", OnOK)
```

- [ ] **Step 3: Verificar Shift+H (use single-account)**

Com o Dofus aberto, pressionar `Shift+H`. Resultado esperado:
- Janela "ZapNavigator - Destino" abre com fundo escuro `#1A1510`
- Texto e ListBox com fundo `#2B2218` e texto âmbar
- Edit com fundo `#2B2218`
- Botão OK em negrito dourado `#C89B3C`
- Botão Cancel normal

- [ ] **Step 4: Verificar Ctrl+H (useAll com seleção de contas)**

Pressionar `Ctrl+H`. Resultado esperado: mesmo visual do passo anterior + checkboxes de contas com texto âmbar para ativas e `#8A7355` para desabilitadas.

- [ ] **Step 5: Commit**

```bash
git add src/clients/zap.ahk
git commit -m "feat: apply GuiTheme to ZapNavigator getDestination GUI"
```

---

## Task 4: Substituir `InputBox` do `TravelNavigator` por `Gui` temático

**Files:**
- Modify: `src/clients/travel.ahk`

> **Contexto:** `TravelNavigator.use()` usa `InputBox(...)` nativo do sistema, que não pode ser temático. Precisamos substituir por um `Gui` próprio que replica o mesmo comportamento: exibe um campo Edit, aguarda OK/Cancel com loop `Sleep(50)`, valida com RegEx e dispara o comando de viagem. A lógica de negócio (RegEx, `openChat`, `sendText`, etc.) permanece idêntica.

- [ ] **Step 1: Reescrever `TravelNavigator.use()` em `src/clients/travel.ahk`**

Substituir o conteúdo completo do método `use()`:

```ahk
    use() {
        state := { value: "", done: false }

        myGui := Gui("+AlwaysOnTop", "Coordenadas")
        GuiTheme.Apply(myGui)
        myGui.Add("Text", "x10 y10 w200", "xx,yy")
        editCtrl := myGui.Add("Edit", "x10 y30 w200 vValue")
        myGui.Add("Button", "x10 y60 w80", "Cancel").OnEvent("Click", OnCancel)
        okBtn := myGui.Add("Button", "x+10 y60 w80 Default", "OK")
        okBtn.SetFont("bold c" Format("{:06X}", GuiTheme.ACCENT))
        okBtn.OnEvent("Click", OnOK)
        myGui.OnEvent("Close", OnClose)
        myGui.Show()
        editCtrl.Focus()

        OnOK(*) {
            state.value := myGui["Value"].Value
            state.done := true
            myGui.Destroy()
        }

        OnCancel(*) {
            state.done := true
            myGui.Destroy()
        }

        OnClose(g) {
            state.done := true
            g.Destroy()
        }

        while !state.done
            Sleep(50)

        if (state.value = "")
            return false

        ; Aceita: xx,yy | [xx,yy | xx,yy] | [xx,yy] | /travel xx,yy | xx,yy]. | xx,yy], (e variantes com colchetes, ponto ou vírgula no fim)
        if !RegExMatch(Trim(state.value), "i)^(?:/travel\s*)?\[?\s*(-?\d+\s*,\s*-?\d+)\s*\]?[.,]?$", &m) {
            ToolTip("Formato inválido. Use xx,yy")
            Sleep(1500)
            ToolTip("")
            return false
        }

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
```

- [ ] **Step 2: Verificar Ctrl+T (TravelNavigator)**

Com o Dofus aberto no personagem principal, pressionar `Ctrl+T`. Resultado esperado:
- Janela "Coordenadas" aparece com fundo escuro `#1A1510`
- Edit temático com fundo `#2B2218`
- Botão OK em negrito dourado
- Digitar `-10,20` e pressionar Enter/OK → viagem executada normalmente
- Pressionar Cancel → nada acontece

- [ ] **Step 3: Verificar formato inválido**

Abrir `Ctrl+T`, digitar `abc` e pressionar OK. Resultado esperado: tooltip "Formato inválido. Use xx,yy" aparece por 1.5s e some.

- [ ] **Step 4: Commit**

```bash
git add src/clients/travel.ahk
git commit -m "feat: replace InputBox with themed Gui in TravelNavigator"
```

---

## Convenção para GUIs Futuros

Todo novo GUI deve seguir o padrão de duas linhas após a criação:

```ahk
myGui := Gui(options, title)
GuiTheme.Apply(myGui)
; ... adicionar controles normalmente
; Para botão OK: okBtn.SetFont("bold c" Format("{:06X}", GuiTheme.ACCENT))
```

Não é necessário nenhum `#Include` extra — `gui_theme.ahk` já está carregado via `header.ahk`.
