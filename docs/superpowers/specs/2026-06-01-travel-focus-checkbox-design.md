# Design: Checkbox "Focar personagem principal?" no TravelNavigator

**Data:** 2026-06-01

## Objetivo

Adicionar um checkbox "Focar personagem principal?" ao diálogo de travel. Quando marcado (default: true), o script foca a janela do personagem principal antes de enviar o comando `/travel`, garantindo que o comando seja enviado para a janela correta.

## Mudanças

### `src/clients/travel.ahk`

- Substituir `InputBox` por um `Gui` AHK v2 com:
  - Controle `Edit` para entrada de coordenadas (placeholder `xx,yy`)
  - Controle `CheckBox` com label "Focar personagem principal?", marcado por default (`Value: 1`)
  - Botões OK e Cancelar
- Construtor `__New(client, account, mainCharacter)` — recebe `AccountManager` e o nome do personagem principal
- Em `use()`, antes de `openChat()`: se checkbox marcado → `this.account.focus(this.mainCharacter)`
- Validação de coordenadas e fluxo de cancelamento permanecem iguais

### `src/utils/init.ahk`

- `Init.__New(config, mainCharacter)` passa a receber `mainCharacter` como parâmetro
- `TravelNavigator` instanciado com: `TravelNavigator(this.client, this.account, mainCharacter)`

### `index.ahk`

- `Init` chamado com `mainCharacter`: `app := Init(config, MAIN_CHARACTER)`
- Remover `app.account.focus(MAIN_CHARACTER)` do hotkey `$^t` (comportamento movido para dentro de `TravelNavigator`)

## Fluxo de execução

```
Hotkey $^t
  → app.travel.use()
    → exibe Gui (Edit + CheckBox)
    → usuário preenche coordenadas e configura checkbox
    → [se checkbox marcado] account.focus(mainCharacter)
    → openChat() → sendText("/travel xx,yy") → confirm() → sendKey("{Esc}")
```

## Restrições

- Sem alteração nas coordenadas de `config.json`
- Sem alteração nos retornos de `ZapNavigator.use()`, `ZapNavigator.useAll()`, ou `AccountManager.getOpenAccounts()`
- `TravelNavigator.use()` continua retornando `Boolean`
