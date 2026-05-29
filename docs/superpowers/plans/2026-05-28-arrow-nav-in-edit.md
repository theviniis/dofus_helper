# Arrow Navigation in Edit — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Quando o `Edit` (`NewDestination`) está focado na GUI do ZapNavigator, pressionar `Up`/`Down` navega pelo histórico de destinos com wrap-around, copiando o item selecionado para o campo.

**Architecture:** Três closures (`NavUp`, `NavDown`, `CleanupHotkeys`) são definidas dentro de `getDestination()` para capturar `currentIndex`, `allDests` e `myGui` por referência. Hotkeys são registradas com `HotIfWinActive("ZapNavigator - Destino")` antes de `myGui.Show()` e desregistradas em `OnOK`, `OnCancel` e `OnClose`.

**Tech Stack:** AutoHotkey v2.0 — `HotKey()`, `HotIfWinActive()`, closures aninhadas.

---

## Arquivo afetado

- Modify: `src/clients/zap.ahk` — método `getDestination()` (linhas 42–142)

---

## Task 1: Implementar navegação por setas no `Edit`

**Files:**
- Modify: `src/clients/zap.ahk:42-142`

---

- [ ] **Step 1: Adicionar variável de estado `currentIndex`**

Em `src/clients/zap.ahk`, na linha 45, após `state := { result: "", done: false }`, adicionar:

```ahk
        state := { result: "", done: false }
        currentIndex := 0
```

`currentIndex = 0` representa "nenhum item selecionado". Os valores 1..`allDests.Length` são as posições válidas.

---

- [ ] **Step 2: Adicionar as closures `NavUp`, `NavDown` e `CleanupHotkeys` antes de `OnOK`**

Inserir o bloco abaixo imediatamente antes da linha `OnOK(*) {` (linha 96):

```ahk
        NavUp(*) {
            if (currentIndex = 0 || currentIndex = 1)
                currentIndex := allDests.Length
            else
                currentIndex--
            myGui["SelectedDestination"].Choose(currentIndex)
            myGui["NewDestination"].Value := allDests[currentIndex]
        }

        NavDown(*) {
            if (currentIndex = 0 || currentIndex = allDests.Length)
                currentIndex := 1
            else
                currentIndex++
            myGui["SelectedDestination"].Choose(currentIndex)
            myGui["NewDestination"].Value := allDests[currentIndex]
        }

        CleanupHotkeys(*) {
            HotIfWinActive("ZapNavigator - Destino")
            try HotKey("Up", NavUp, "Off")
            try HotKey("Down", NavDown, "Off")
            HotIfWinActive()
        }

```

`try` em `CleanupHotkeys` evita erro caso a função seja chamada quando `hasHistory` era falso (hotkeys nunca foram registradas).

---

- [ ] **Step 3: Chamar `CleanupHotkeys()` em `OnOK`**

Modificar `OnOK` adicionando `CleanupHotkeys()` como primeira linha:

```ahk
        OnOK(*) {
            CleanupHotkeys()
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
                for accountName, _ in this.account.account {
                    if (myGui["__cb_" accountName].Value)
                        selected.Push(accountName)
                }
                this.selectedAccounts := selected
            }
            state.done := true
            myGui.Destroy()
        }
```

---

- [ ] **Step 4: Chamar `CleanupHotkeys()` em `OnCancel` e `OnClose`**

```ahk
        OnCancel(*) {
            CleanupHotkeys()
            state.done := true
            myGui.Destroy()
        }

        OnClose(GuiObj) {
            CleanupHotkeys()
            state.done := true
            GuiObj.Destroy()
        }
```

---

- [ ] **Step 5: Registrar as hotkeys antes de `myGui.Show()`**

Inserir o bloco abaixo imediatamente antes da linha `myGui.Show()` (linha 130):

```ahk
        if (hasHistory) {
            HotIfWinActive("ZapNavigator - Destino")
            HotKey("Up", NavUp)
            HotKey("Down", NavDown)
            HotIfWinActive()
        }
        myGui.Show()
```

O `HotIfWinActive()` sem argumento ao final reseta o critério global, evitando afetar outros hotkeys do script.

---

- [ ] **Step 6: Verificar manualmente**

1. Recarregar o script no AutoHotkey.
2. Ter ao menos um destino no `history.txt` (ou fazer uma viagem para gerar histórico).
3. Pressionar `Shift+H` ou `Ctrl+H` para abrir a GUI — o `Edit` deve estar focado.
4. Pressionar `Down`: o primeiro item da lista deve aparecer no `Edit` e ficar destacado no `ListBox`.
5. Pressionar `Down` novamente: próximo item.
6. Pressionar `Up` no primeiro item: deve ir para o último (wrap-around).
7. Pressionar `Up` no último item: deve ir para o primeiro (wrap-around).
8. Com um item selecionado no `Edit`, pressionar `OK`: deve navegar para o destino selecionado.
9. Abrir a GUI sem histórico (`history.txt` vazio ou inexistente): `Up`/`Down` não devem fazer nada.

---

- [ ] **Step 7: Commit**

```bash
git add src/clients/zap.ahk
git commit -m "feat: navigate recent destinations with Up/Down when Edit is focused"
```
