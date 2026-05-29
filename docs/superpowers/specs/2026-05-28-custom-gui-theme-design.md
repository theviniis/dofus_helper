# Custom GUI Theme — Design Spec

**Date:** 2026-05-28
**Branch:** feat/arrow_nav (worktree: better_ui)

---

## Objetivo

Aplicar um tema visual escuro com paleta dark fantasy / âmbar dourado (inspirado no Dofus) em todos os GUIs do projeto. O tema deve ser centralizado e reutilizável, com impacto mínimo no código existente.

---

## Paleta de Cores e Fonte

As cores ficam em variáveis estáticas na classe `GuiTheme`:

| Variável        | Valor       | Uso                              |
|-----------------|-------------|----------------------------------|
| `BG_DARK`       | `0x1A1510`  | Fundo da janela                  |
| `BG_CONTROL`    | `0x2B2218`  | Fundo de Edit, ListBox           |
| `FG_TEXT`       | `0xE8D5A3`  | Texto principal (âmbar claro)    |
| `FG_DIM`        | `0x8A7355`  | Texto desabilitado               |
| `ACCENT`        | `0xC89B3C`  | Fonte em negrito do botão OK     |
| `BG_BUTTON`     | `0x3D2E1A`  | Fundo de todos os botões         |
| `FONT_NAME`     | `"Segoe UI"`| Fonte principal                  |
| `FONT_SIZE`     | `10`        | Tamanho padrão                   |

---

## Módulo `GuiTheme.ahk`

**Localização:** `src/utils/gui_theme.ahk`

### Estrutura

```ahk
class GuiTheme {
    static BG_DARK      := 0x1A1510
    static BG_CONTROL   := 0x2B2218
    static FG_TEXT      := 0xE8D5A3
    static FG_DIM       := 0x8A7355
    static ACCENT       := 0xC89B3C
    static BG_BUTTON    := 0x3D2E1A
    static FONT_NAME    := "Segoe UI"
    static FONT_SIZE    := 10

    static Apply(gui) { ... }
    static ApplyControl(ctrl, type) { ... }
    static _OnCtlColor(wParam, lParam, msg, hwnd) { ... }
}
```

### `Apply(gui)`

1. Define `gui.BackColor := GuiTheme.BG_DARK`
2. Chama `gui.SetFont("s" GuiTheme.FONT_SIZE " c" GuiTheme.FG_TEXT, GuiTheme.FONT_NAME)`
3. Registra `OnMessage(WM_CTLCOLORBTN, GuiTheme._OnCtlColor)` e `OnMessage(WM_CTLCOLORSTATIC, GuiTheme._OnCtlColor)` para colorir botões e checkboxes via Win32

### `ApplyControl(ctrl, type)`

Chamado após cada `gui.Add(...)` para controles que precisam de `BackColor` individual:
- `"Edit"` → `ctrl.Opt("Background" GuiTheme.BG_CONTROL " c" GuiTheme.FG_TEXT)`
- `"ListBox"` → `ctrl.Opt("Background" GuiTheme.BG_CONTROL " c" GuiTheme.FG_TEXT)`

### `_OnCtlColor(wParam, lParam, msg, hwnd)`

Handler Win32 chamado pelo Windows ao renderizar botões, checkboxes e labels estáticos. `msg` distingue o tipo de controle:

- `WM_CTLCOLORBTN` (botões): `SetTextColor(hdc, FG_TEXT)`, `SetBkColor(hdc, BG_BUTTON)`, retorna brush de `BG_BUTTON`
- `WM_CTLCOLORSTATIC` (checkboxes/labels): verifica `IsWindowEnabled(lParam)` via DllCall — se desabilitado usa `FG_DIM`, caso contrário `FG_TEXT`; `SetBkColor(hdc, BG_DARK)`, retorna brush de `BG_DARK`

---

## Alterações nos GUIs Existentes

### `ZapNavigator.getDestination()` — `src/clients/zap.ahk`

```ahk
myGui := Gui("+AlwaysOnTop", "ZapNavigator - Destino")
GuiTheme.Apply(myGui)

; Após cada Add de Edit/ListBox:
listCtrl := myGui.Add("ListBox", ...)
GuiTheme.ApplyControl(listCtrl, "ListBox")

editCtrl := myGui.Add("Edit", ...)
GuiTheme.ApplyControl(editCtrl, "Edit")
```

Checkboxes desabilitadas recebem `FG_DIM` automaticamente via `_OnCtlColor` pelo HWND do controle.

### `TravelNavigator.use()` — `src/clients/travel.ahk`

Substituir `InputBox(...)` nativo por `Gui` próprio:

```ahk
use() {
    state := { result: "", done: false }
    myGui := Gui("+AlwaysOnTop", "Coordenadas")
    GuiTheme.Apply(myGui)
    myGui.Add("Text", ..., "xx,yy")
    editCtrl := myGui.Add("Edit", "vValue ...")
    GuiTheme.ApplyControl(editCtrl, "Edit")
    myGui.Add("Button", "...", "Cancel").OnEvent("Click", OnCancel)
    okBtn := myGui.Add("Button", "... Default", "OK")
    okBtn.SetFont("bold c" GuiTheme.ACCENT)  ; destaque dourado no botão OK
    okBtn.OnEvent("Click", OnOK)
    ; ... lógica de wait e validação RegEx inalterada
}
```

A validação com RegEx permanece idêntica — só a camada de UI muda.

---

## Inclusão Global

Adicionar em `src/utils/header.ahk`:

```ahk
#Include ./gui_theme.ahk
```

Isso disponibiliza `GuiTheme` para todos os arquivos sem necessidade de include individual.

---

## Convenção para GUIs Futuros

Todo novo GUI deve seguir o padrão:

```ahk
myGui := Gui(options, title)
GuiTheme.Apply(myGui)
; ... adicionar controles
; Para Edit e ListBox: GuiTheme.ApplyControl(ctrl, "Edit") após Add
```

---

## Sem Mudanças em

- `index.ahk` — hotkeys inalteradas
- `config.json` — nenhuma entrada de tema
- `AccountManager`, `ClientInterface`, `Init` — sem alterações
- Lógica de negócio de `ZapNavigator` e `TravelNavigator` — só a camada de UI muda
