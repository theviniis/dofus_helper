# Design: Navegação por setas no Edit do histórico

**Data:** 2026-05-28  
**Branch:** feat/arrow_nav  
**Arquivo afetado:** `src/clients/zap.ahk` — método `getDestination()`

---

## Objetivo

Quando a GUI do ZapNavigator está aberta e o `Edit` (`NewDestination`) está focado, pressionar `Up` ou `Down` deve navegar pelo histórico de destinos recentes (`ListBox` `SelectedDestination`), copiando o item selecionado para o campo `Edit`.

---

## Escopo

- Restrito ao método `getDestination()` em `ZapNavigator`.
- Só ativo quando `hasHistory` é verdadeiro (há itens no histórico).
- Não altera a lógica de submissão, cancelamento ou leitura do histórico.

---

## Comportamento

### Variável de estado

```
currentIndex := 0   ; 0 = sem seleção (estado inicial)
```

### Pressionar `Up`

| `currentIndex` atual | Novo `currentIndex` |
|----------------------|---------------------|
| 0                    | 1 (primeiro item)   |
| 1                    | `allDests.Length` (wrap para último) |
| N (qualquer outro)   | N - 1               |

### Pressionar `Down`

| `currentIndex` atual      | Novo `currentIndex` |
|---------------------------|---------------------|
| 0                         | 1 (primeiro item)   |
| `allDests.Length` (último)| 1 (wrap para primeiro) |
| N (qualquer outro)        | N + 1               |

### Após atualizar o índice (ambas as teclas)

1. `myGui["SelectedDestination"].Choose(currentIndex)` — destaca o item no `ListBox`.
2. `myGui["NewDestination"].Value := allDests[currentIndex]` — copia o texto para o `Edit`.
3. O foco permanece no `Edit` (não é transferido para o `ListBox`).

---

## Implementação

### Registro das hotkeys

Após criar os controles e antes de `myGui.Show()`, registrar as hotkeys escopadas à janela:

```ahk
HotIfWinActive("ZapNavigator - Destino")
HotKey("Up", OnUp)
HotKey("Down", OnDown)
HotIfWinActive()   ; reset do escopo
```

As funções `OnUp` e `OnDown` são closures que capturam `currentIndex`, `allDests`, e `myGui`.

### Limpeza das hotkeys

Uma função `CleanupHotkeys()` desregistra as hotkeys:

```ahk
CleanupHotkeys() {
    HotIfWinActive("ZapNavigator - Destino")
    HotKey("Up", OnUp, "Off")
    HotKey("Down", OnDown, "Off")
    HotIfWinActive()
}
```

Chamada em `OnOK`, `OnCancel` e `OnClose` — garante que as hotkeys não vazem independentemente de como a GUI for fechada.

---

## O que não muda

- A lógica de `OnOK` lê `NewDestination.Value` (já contém o texto navegado, funciona sem alteração).
- `OnCancel` e `OnClose` permanecem iguais, apenas ganham a chamada a `CleanupHotkeys()`.
- Nenhuma alteração em `TravelHistory`, `TravelNavigator` ou outros arquivos.
