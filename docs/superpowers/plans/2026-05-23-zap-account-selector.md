# Zap Account Selector Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Exibir um GUI unificado ao pressionar `Ctrl+H` que combina a seleção de destino e a seleção de contas (via checkboxes) que realizarão a viagem de zap.

**Architecture:** Toda a mudança fica em `src/clients/zap.ahk`. `ZapNavigator` ganha a propriedade `selectedAccounts` e `getDestination()` recebe o parâmetro `showAccounts` que, quando `true`, acrescenta uma coluna direita com checkboxes ao GUI existente. `useAll()` passa a chamar `getDestination(true)` e itera sobre `this.selectedAccounts`.

**Tech Stack:** AutoHotkey v2.0 — `Gui`, `CheckBox`, `ListBox`, `Edit`, posicionamento via opções `Section`/`ys`/`x<n>`.

---

## Mapa de arquivos

| Arquivo | Ação | O que muda |
|---------|------|------------|
| `src/clients/zap.ahk` | Modificar | Propriedade `selectedAccounts`, parâmetro em `getDestination()`, coluna de checkboxes, `useAll()` simplificado |

Nenhum outro arquivo é tocado.

---

## Task 1: Adicionar propriedade `selectedAccounts` ao construtor

**Files:**
- Modify: `src/clients/zap.ahk:4-11`

- [ ] **Step 1: Abrir o arquivo e localizar o construtor**

O construtor está entre as linhas 4–11 de `src/clients/zap.ahk`:

```ahk
__New(travelersBagConfig, client, travelHistory, account) {
    this.travelersBagConfig := travelersBagConfig
    this.client := client
    this.travelHistory := travelHistory
    this.running := false
    this.destination := ""
    this.account := account
}
```

- [ ] **Step 2: Adicionar a propriedade `selectedAccounts`**

Inserir `this.selectedAccounts := []` logo após `this.destination := ""`:

```ahk
__New(travelersBagConfig, client, travelHistory, account) {
    this.travelersBagConfig := travelersBagConfig
    this.client := client
    this.travelHistory := travelHistory
    this.running := false
    this.destination := ""
    this.selectedAccounts := []
    this.account := account
}
```

- [ ] **Step 3: Verificar que o script carrega sem erro**

Recarregar o script no AHK (clique direito no ícone da bandeja → Reload). Verificar que nenhum MsgBox de erro aparece e o ícone continua na bandeja.

- [ ] **Step 4: Commit**

```bash
git add src/clients/zap.ahk
git commit -m "feat: add selectedAccounts property to ZapNavigator"
```

---

## Task 2: Estender `getDestination()` com coluna de checkboxes

**Files:**
- Modify: `src/clients/zap.ahk:37-95` (método `getDestination`)

Esta task substitui o método `getDestination()` inteiro pela versão que aceita `showAccounts := false` e, quando `true`, acrescenta a coluna direita com checkboxes.

- [ ] **Step 1: Substituir o método `getDestination()` completo**

Substituir tudo entre `getDestination() {` e o `}` de fechamento do método pelo código abaixo:

```ahk
getDestination(showAccounts := false) {
    if (!showAccounts && this.destination != "") {
        return this.destination
    }

    allDests := this.travelHistory.getAll()
    hasHistory := allDests.Length > 0
    state := { result: "", done: false }

    myGui := Gui("+AlwaysOnTop", "ZapNavigator - Destino")
    myGui.SetFont("s10")
    myGui.Add("Text", "Section w300", "Selecione ou digite o destino:")

    if (hasHistory) {
        myGui.Add("ListBox", "vSelectedDestination w300 h150", allDests)
    }

    myGui.Add("Edit", "vNewDestination w300")

    if (showAccounts) {
        myGui.Add("Text", "x330 ys w150", "Contas:")
        for accountName, windowName in this.account.account {
            isOpen := this.client.windowExists(windowName)
            if (this.selectedAccounts.Length = 0) {
                isChecked := isOpen
            } else {
                isChecked := false
                for _, name in this.selectedAccounts {
                    if (name = accountName) {
                        isChecked := isOpen
                        break
                    }
                }
            }
            opts := "x330 w150 v__cb_" accountName
            if (!isOpen)
                opts .= " Disabled"
            if (isChecked)
                opts .= " Checked"
            myGui.Add("CheckBox", opts, accountName)
        }
    }

    OnOK(*) {
        newDest := Trim(myGui["NewDestination"].Value)
        if (newDest != "") {
            state.result := newDest
        } else if (hasHistory) {
            try {
                state.result := myGui["SelectedDestination"].Text
            }
        }
        if (showAccounts) {
            selected := []
            for accountName, windowName in this.account.account {
                try {
                    if (myGui["__cb_" accountName].Value)
                        selected.Push(accountName)
                }
            }
            this.selectedAccounts := selected
        }
        state.done := true
        myGui.Destroy()
    }

    OnCancel(*) {
        state.done := true
        myGui.Destroy()
    }

    OnClose(GuiObj) {
        state.done := true
        GuiObj.Destroy()
    }

    myGui.Add("Button", "w80", "Cancel").OnEvent("Click", OnCancel)
    myGui.Add("Button", "x+10 w80 Default", "OK").OnEvent("Click", OnOK)
    myGui.OnEvent("Close", OnClose)
    myGui.Show()
    myGui["NewDestination"].Focus()

    while !state.done {
        Sleep(50)
    }

    if (state.result != "") {
        this.destination := state.result
        this.travelHistory.add(state.result)
    }

    return this.destination
}
```

- [ ] **Step 2: Verificar que `Shift+H` ainda abre o GUI sem checkboxes**

Pressionar `Shift+H` no jogo. O GUI deve aparecer apenas com o campo de destino e histórico (sem coluna de contas) — comportamento idêntico ao anterior.

- [ ] **Step 3: Verificar regressão — cancelar não viaja**

Com `Shift+H`, fechar o GUI via Cancel ou X. Confirmar que nenhuma viagem é iniciada.

- [ ] **Step 4: Commit**

```bash
git add src/clients/zap.ahk
git commit -m "feat: add account checkboxes column to getDestination GUI"
```

---

## Task 3: Atualizar `useAll()` para usar `getDestination(true)` e `selectedAccounts`

**Files:**
- Modify: `src/clients/zap.ahk:138-173` (método `useAll`)

- [ ] **Step 1: Substituir o método `useAll()` completo**

Substituir tudo entre `useAll() {` e o `}` de fechamento pelo código abaixo:

```ahk
useAll() {
    priorWindow := WinExist("A")
    openAccounts := this.account.getOpenAccounts()

    if (openAccounts.Length = 0) {
        return
    }

    dest := this.getDestination(true)
    if (dest = "" || this.selectedAccounts.Length = 0) {
        return
    }

    for accountName in this.selectedAccounts {
        this.account.focus(accountName)
        Sleep(SLEEP_TIME)

        if (!this.use(false)) {
            return
        }
    }

    this.destination := ""
    WinActivate(priorWindow)

    Sleep(SLEEP_TIME)
    this.client.allowAllyToFollowLeader()
}
```

**O que mudou em relação ao original:**
- Remove o bloco de reordenação da conta ativa (não necessário com seleção explícita).
- Remove `this.destination := ""` do início — `getDestination(true)` já exibe o GUI independentemente.
- Chama `getDestination(true)` para obter destino + seleção de contas num único GUI.
- Aborta se `dest` for vazio (Cancel) **ou** se nenhuma conta foi marcada.
- Itera sobre `this.selectedAccounts` em vez de `openAccounts`.
- Mantém `this.destination := ""` ao final para forçar nova entrada no próximo `Shift+H`.

- [ ] **Step 2: Verificar o fluxo completo — todas as contas marcadas**

1. Ter ao menos 2 janelas do Dofus abertas.
2. Pressionar `Ctrl+H`.
3. Confirmar que o GUI aparece com coluna esquerda (destino) e coluna direita (checkboxes com as contas abertas já marcadas).
4. Digitar um destino e deixar todas as contas marcadas.
5. Clicar OK.
6. Confirmar que todas as contas marcadas viajam para o destino.

- [ ] **Step 3: Verificar fluxo parcial — subset de contas**

1. Pressionar `Ctrl+H`.
2. Desmarcar uma conta no checkbox.
3. Digitar destino e clicar OK.
4. Confirmar que apenas as contas marcadas viajam.

- [ ] **Step 4: Verificar persistência — segunda abertura pré-preenche a seleção anterior**

1. Pressionar `Ctrl+H` e marcar apenas `panda` e `iop`. Confirmar com OK.
2. Pressionar `Ctrl+H` novamente.
3. Confirmar que o GUI abre com `panda` e `iop` pré-marcados.

- [ ] **Step 5: Verificar abortar com Cancel não viaja**

Pressionar `Ctrl+H`, clicar Cancel ou fechar o GUI. Confirmar que nenhuma conta viaja.

- [ ] **Step 6: Verificar abortar sem conta marcada não viaja**

Pressionar `Ctrl+H`, desmarcar todas as contas, clicar OK. Confirmar que nenhuma conta viaja.

- [ ] **Step 7: Verificar que `Shift+H` (conta única) continua sem checkboxes**

Pressionar `Shift+H`. Confirmar que o GUI exibe apenas o campo de destino, sem coluna de contas.

- [ ] **Step 8: Commit**

```bash
git add src/clients/zap.ahk
git commit -m "feat: update useAll to use unified destination+account GUI"
```
