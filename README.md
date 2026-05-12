# Dofus AutoHotkey Scripts

Scripts de automação AutoHotkey v2.0 para o jogo **Dofus**, oferecendo troca de contas via hotkeys e viagem coordenada usando o item "Zap" (Saco de Viagens). Detecção de UI baseada em pixels executa workflows automatizados sem dependências externas. Um único hotkey dispara zap sequencial em todas as contas abertas.

## Estrutura do Projeto

```
.
├── index.ahk                     # Entry point principal; hotkeys, DI, config
├── config.json                   # Nomes de janela e coordenadas de pixel
├── src/
│   ├── clients/
│   │   ├── account.ahk            # AccountManager
│   │   ├── client.ahk            # ClientInterface
│   │   ├── travel.ahk           # TravelNavigator
│   │   ├── travel_history.ahk    # TravelHistory
│   │   └── zap.ahk              # ZapNavigator
│   └── utils/
│       ├── header.ahk            # Header comum
│       ├── JSON.ahk              # Parser JSON
│       ├── init.ahk              # DI composition root
│       ├── copy_pixel_color_and_position.ahk
│       ├── debug_array.ahk
│       ├── send_tooltip.ahk
│       └── ...
├── docs/superpowers/specs/       # Especificações por data
├── docs/superpowers/plans/       # Planos por data
└── .vscode/                      # Configurações do editor
```

## Como Usar

1. Instale o [AutoHotkey v2.0](https://www.autohotkey.com/)
2. Execute o script `index.ahk`
3. Use os atalhos no jogo Dofus

### Atalhos

| Atalho | Ação |
|--------|------|
| `Win+1` | Focar conta "iop" |
| `Win+2` | Focar conta "eni" |
| `Win+3` | Focar conta "cra" |
| `Win+4` | Focar conta "sac" |
| `Ctrl+t` | Viagem single-account (TravelNavigator.use) |
| `Win+h` | Zap single-account (ZapNavigator.use) |
| `Ctrl+h` | Zap multi-account (ZapNavigator.useAll) |
| `Ctrl+Esc` | Parar o loop do ZapNavigator |
| `Win+c` | Copiar nome da janela ativa para clipboard |

## Arquitetura

```
index.ahk (hotkeys + raiz DI)
    │
    ├── ClientInterface (src/clients/client.ahk)
    │       ├── focusWindow(windowName) → WinActivate
    │       ├── windowExists(windowName) → WinExist
    │       ├── clickAt(coordName) → Click coordenadas do config
    │       ├── pixelMatches(coordName) → PixelGetColor comparison
    │       └── sendText/sendKey/confirm → Send keystrokes
    │
    ├── AccountManager (src/clients/account.ahk)
    │       ├── focus(accountName) → lookup window + focus
    │       ├── getOpenAccounts() → array de nomes de contas abertas
    │       └── getAccountByWindow(windowId) → reverse lookup
    │
    ├── ZapNavigator (src/clients/zap.ahk)
    │       ├── isZapInterfaceOpen / isOnTravelScreen → pixel detection
    │       ├── use(forceInput?) → zap single-account (retorna Boolean)
    │       ├── useAll() → zap multi-account (orquestra todas abertas)
    │       ├── getDestination() → GUI para seleção de destino
    │       ├── destination property → reutilizado entre contas
    │       └── stop() → halt running operation
    │
    ├── TravelNavigator (src/clients/travel.ahk)
    │       └── use() → coordenadas via InputBox, envia comando /travel
    │
    └── TravelHistory (src/clients/travel_history.ahk)
            ├── getAll() → lê history.txt
            ├── add(destination) → prepend, dedup, limita a 10
            └── save(destinations) → escreve em history.txt
```

**Fluxo de dados:** Hotkey → Método da Classe → lookup config → interação com UI

## Configuração

As coordenadas de pixel e nomes de janela estão em `config.json`:

```json
{
  "accounts": {
    "iop": "Bate-no-sigilo - Iop - 3.5.14.18 - Release"
  },
  "travelersBag": {
    "zap": {
      "click": [1165, 554],
      "detect": { "pos": [1445, 429], "color": "0xA75F20" }
    }
  }
}
```

- `accounts` — Nome das janelas do Dofus (verifique com `Win+c`)
- `travelersBag` — Coordenadas de clique e detecção de pixel para cada interface

## Requisitos

- Windows
- AutoHotkey v2.0
- Dofus.exe

## Notas

- Coordenadas de pixel são específicas para a versão do Dofus e podem precisar de ajuste após updates
- Testes manuais necessários para validar funcionamento
- Sem testes automatizados configurados
