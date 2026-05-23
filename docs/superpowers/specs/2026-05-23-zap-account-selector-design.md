# Zap Account Selector — Design Spec

**Date:** 2026-05-23
**Branch:** feat/travel_targets
**File affected:** `src/clients/zap.ahk`

---

## Objetivo

Ao pressionar `Ctrl+H`, exibir um GUI unificado que pergunta o destino e permite selecionar quais contas cadastradas em `config.json` realizarão a viagem de zap.

---

## Comportamento

- O GUI é exibido **toda vez** que `Ctrl+H` é pressionado.
- A seleção de contas é **pré-preenchida** com a última seleção salva.
- Na **primeira abertura** (sem seleção salva), todas as contas com janela aberta vêm pré-marcadas.
- Contas **fechadas** aparecem na lista mas ficam desabilitadas (não selecionáveis).
- Se nenhuma conta estiver marcada ao confirmar, a ação é abortada (equivale a Cancel).

---

## Layout do GUI

```
┌─ ZapNavigator - Destino ──────────────────────────────────┐
│                                                            │
│  Selecione ou digite o destino:  │  Contas:               │
│  ┌─────────────────────────────┐ │  ☑ panda               │
│  │  [ListBox - histórico]      │ │  ☑ iop                 │
│  │                             │ │  ☐ eni  (desabilitada) │
│  └─────────────────────────────┘ │  ☑ enu                 │
│  [_______ novo destino ________] │                        │
│                                                            │
│                      [Cancel]  [OK]                        │
└────────────────────────────────────────────────────────────┘
```

- Coluna esquerda: destino (igual ao GUI atual).
- Coluna direita: checkboxes verticais, um por conta de `config.json`.
- Contas fechadas: `Disabled`, desmarcadas.

---

## Mudanças em `ZapNavigator`

### Nova propriedade

```ahk
selectedAccounts := []
```

Inicializada vazia no construtor. Array de strings com os nomes das contas selecionadas. Persiste entre pressões de `Ctrl+H`.

### `getDestination(showAccounts := false)`

- Parâmetro `showAccounts` adicionado — padrão `false` preserva comportamento atual para `use()` (Shift+H).
- Quando `showAccounts = false`: comportamento idêntico ao atual (retorna `this.destination` cacheado se já definido).
- Quando `showAccounts = true`: **sempre exibe o GUI** (ignora `this.destination` cacheado), pois a seleção de contas precisa ser confirmada a cada chamada.
  - Renderiza a coluna direita com um `Checkbox` por conta de `config.json`.
  - Lógica de pré-marcação:
    - Se `this.selectedAccounts` estiver vazio (primeira vez): pré-marca todas as contas abertas.
    - Se `this.selectedAccounts` não estiver vazio: pré-marca as contas que estão em `this.selectedAccounts` **e** têm janela aberta.
  - Conta fechada → `Disabled`, desmarcada independentemente da seleção anterior.
  - No OK: salva `this.selectedAccounts` com os nomes das contas marcadas.
  - Se array resultante vazio → aborta (retorna `""`).

### `useAll()`

- Chama `getDestination(true)` para obter destino e seleção de contas em um único GUI.
- Itera sobre `this.selectedAccounts` em vez de `openAccounts`.
- Remove `this.destination := ""` do início — `getDestination(true)` sempre exibe o GUI e atualiza o destino.

---

## Sem mudanças em

- `index.ahk` — `Ctrl+H` continua chamando `app.zap.useAll()`.
- `use()` — continua usando `getDestination()` sem parâmetro; comportamento inalterado.
- `AccountManager`, `ClientInterface`, `Init`, `config.json`.
