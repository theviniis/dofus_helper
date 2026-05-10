# Zap Navigator InputBox Design

## Overview

Adicionar InputBox para coletar destino do usuário ao usar a funcionalidade de viagem via Zap. O texto será automaticamente colado na searchBar após o usuário confirmar no InputBox.

## Flow

1. Usuário pressiona `h` → chama `travel()`
2. Loop detecta estado da interface:
   - **Se Zap interface aberta**: exibir InputBox → `clickSearch()` → colar texto se存在
   - **Se Travel screen aberta**: `clickZap()`
   - **Caso contrário**: `travel()` (envia "h")

## Implementation

### `ZapNavigator` class

#### New method: `getDestination()`
```autohotkey
getDestination() {
    destination := InputBox(
        "Para onde deseja viajar?",
        "Destino",
        ,
        ,
        ,
        ,
        ,
        ,
        ""
    )
    if (destination.result = "OK" and destination.value != "") {
        return destination.value
    }
    return ""
}
```

#### Modified: `use()` method
```autohotkey
use() {
    this.running := true

    while (this.running) {
        isZapOpen := this.isZapInterfaceOpen
        isTravelOpen := this.isOnTravelScreen

        if (isZapOpen) {
            destination := this.getDestination()
            this.clickSearch()
            if (destination != "") {
                Sleep(300)
                Send(destination)
            }
            break
        }
        else if (isTravelOpen) {
            this.clickZap()
        }
        else {
            this.travel()
        }

        Sleep(500)
    }

    this.running := false
}
```

## Behavior

| Scenario | InputBox | clickSearch() | Colar texto |
|----------|----------|---------------|-------------|
| Usuário digita e confirma | Exibe | Sim | Sim |
| Usuário cancela | Exibe | Sim | Não |
| Usuário deixa vazio e confirma | Exibe | Sim | Não |

## Edge Cases

- InputBox cancelado → retorna string vazia → apenas abre searchBar
- InputBox vazio → retorna string vazia → apenas abre searchBar
- Texto muito longo → não é restrição do caso de uso