# Design: ClientInterface como abstração de interação com o jogo

**Data:** 2026-05-10

## Visão geral

Isolar toda a lógica de interação com janela/jogo (WinActivate, Send, Click, PixelGetColor) no `ClientInterface`, criando uma abstração limpa que其他 módulos utilizam.

## Nova interface do ClientInterface

```autohotkey
class ClientInterface {
    __New(config) {
        this.config := config
        this.sleepTime := 200
    }

    ; Janela
    focusWindow(windowName?)
    waitWindow(windowName)
    windowExists(windowName) => Boolean

    ; Input keyboard
    sendText(text)
    sendKey(key)
    openChat()
    confirm()

    ; Mouse
    clickAt(coordName)  ; "zap", "search" - usa config.sacoDeViagens

    ; Pixel detection
    pixelMatches(coordName) => Boolean  ; "zap", "interfaceZap"

    ; Utilitário
    sleep(ms?)
}
```

## Mudanças por arquivo

### client_interface.ahk
- Receber `config` no construtor
- Implementar todos os métodos acima
- Remover `SLEEP_TIME` constante (usar `this.sleepTime`)

### accounts.ahk
- Mudar construtor para `__New(accountList, clientIF)`
- Usar `clientIF.focusWindow(windowName)` em vez de `WinActivate`
- Usar `clientIF.windowExists(windowName)` em vez de `WinExist`

### use_zap.ahk
- Mudar construtor para `__New(travelersBagConfig, clientIF)`
- Usar `clientIF.pixelMatches("zap")` em vez de `doesPixelMatches()`
- Usar `clientIF.pixelMatches("interfaceZap")`
- Usar `clientIF.clickAt("zap")` em vez de `Click()` direto
- Usar `clientIF.clickAt("search")`
- Usar `clientIF.sendKey("h")` em vez de `Send("h")`
- Usar `clientIF.sendText()` e `clientIF.confirm()`

### does_pixel_matches.ahk
- Remover arquivo (funcionalidade movida para ClientInterface)

### index.ahk
- Passar `config` para `ClientInterface`
- Injetar `clientIF` em `AccountManager`: `acc := AccountManager(config.accountList, clientIF)`
- Atualizar includes se necessário

## Dependency flow

```
index.ahk
    ├── ClientInterface(config)
    ├── AccountManager(config.accountList, clientIF)
    ├── ZapNavigator(config.sacoDeViagens, clientIF)
    └── TravelNavigator(clientIF)
```

## Ordem de implementação

1. Expandir `client_interface.ahk` com novos métodos
2. Atualizar `accounts.ahk` para usar `clientIF`
3. Atualizar `use_zap.ahk` para usar `clientIF`
4. Atualizar `index.ahk` para injetar dependências
5. Remover `does_pixel_matches.ahk`