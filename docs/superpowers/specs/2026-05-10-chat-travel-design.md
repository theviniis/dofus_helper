# Chat Travel via `/travel` — Design Specification

## Overview

Ao pressionar `t`, o usuário insere coordenadas no formato `xx,yy`. O script abre o chat do Dofus, envia o comando `/travel xx,yy` e confirma com Enter.

## Arquitetura

| Classe | Responsabilidade |
|---|---|
| `ClientInterface` | Interage com a UI do cliente Dofus — abrir chat, enviar texto, confirmar |
| `TravelNavigator` | Validação de input, InputBox, orquestração do fluxo |

## Fluxo

1. `TravelNavigator.use()` → `InputBox` com título `"Coordenadas"`, prompt `"xx,yy"`
2. Valida formato com regex `^\d+,\d+$`; se inválido → `ToolTip` erro, retorna `false`
3. `ClientInterface.focusWindow()` → `WinActivate` na janela ativa do Dofus
4. `ClientInterface.openChat()` → pressiona `espaço`
5. `ClientInterface.sendText("/travel 123,456")` → envia texto
6. `ClientInterface.confirm()` → pressiona `Enter`
7. Retorna `true`

## Interface

### ClientInterface

```autohotkey
class ClientInterface {
    __New()
    focusWindow()
    openChat()
    sendText(text)
    confirm()
}
```

### TravelNavigator

```autohotkey
class TravelNavigator {
    __New(clientInterface)
    use() => Boolean
}
```

## Estrutura de arquivos

```
src/utils/
  client_interface.ahk  (nova)
  travel.ahk              (nova)
```

## Hotkey

`$t:: travelNav.use()` — no bloco `#HotIf WinActive("ahk_exe Dofus.exe")` em `index.ahk`

## Validação

- Formato: `^\d+,\d+$` (números, vírgula, números)
- InputBox cancelado → retorna `false`
- Coordenada vazia → retorna `false`
