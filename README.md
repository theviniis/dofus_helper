# Dofus AutoHotkey Scripts

Scripts de automação AutoHotkey v2.0 para o jogo **Dofus**, oferecendo troca de contas via hotkeys e viagem coordenada usando o item "Zap" (Saco de Viagens). Detecção de UI baseada em pixels executa workflows automatizados sem dependências externas. Um único hotkey dispara zap sequencial em todas as contas abertas.

## Estrutura do Projeto

```
.
├── index.ahk                       # Entry point principal; hotkeys, DI, config
├── config.json                     # Nomes de janela e coordenadas de pixel
├── src/
│   ├── clients/
│   │   ├── account.ahk             # AccountManager
│   │   ├── client.ahk              # ClientInterface
│   │   ├── travel.ahk              # TravelNavigator
│   │   ├── travel_history.ahk      # TravelHistory
│   │   ├── zap.ahk                 # ZapNavigator
│   │   └── macro_broadcaster.ahk   # MacroBroadcaster
│   └── utils/
│       ├── header.ahk              # Header comum
│       ├── JSON.ahk                # Parser JSON
│       ├── init.ahk                # DI composition root
│       ├── copy_pixel_color_and_position.ahk
│       ├── debug_array.ahk
│       ├── send_tooltip.ahk
│       └── ...
├── docs/superpowers/specs/         # Especificações por data
├── docs/superpowers/plans/         # Planos por data
└── .vscode/                        # Configurações do editor
```

## Como Usar

1. Instale o [AutoHotkey v2.0](https://www.autohotkey.com/)
2. Execute o script `index.ahk`
3. Use os atalhos no jogo Dofus

### Atalhos

| Atalho     | Ação                                             |
| ---------- | ------------------------------------------------ |
| `Win+1`    | Focar conta "iop"                                |
| `Win+2`    | Focar conta "eni"                                |
| `Win+3`    | Focar conta "cra"                                |
| `Win+4`    | Focar conta "sac"                                |
| `Ctrl+t`   | Viagem single-account (TravelNavigator.use)      |
| `Win+h`    | Zap single-account (ZapNavigator.use)            |
| `Ctrl+h`   | Zap multi-account (ZapNavigator.useAll)          |
| `Ctrl+Esc` | Parar o loop do ZapNavigator                     |
| `Win+c`    | Copiar nome da janela ativa para clipboard       |
| `F9`       | Gravar/replicar macro em todas as contas abertas |

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
    │
    └── MacroBroadcaster (src/clients/macro_broadcaster.ahk)
            ├── toggle() → inicia/para gravação
            ├── startRecording() → hooks keyboard/mouse, salva janela origem
            ├── stopRecording() → replica em todas abertas
            ├── broadcastToAll() → replay exceto origem
            ├── _onKey/_onMouse → captura input
            └── _replayActions() → executa sequência gravada
```

**Fluxo de dados:** Hotkey → Método da Classe → lookup config → interação com UI

## Configuração

Todas as configurações ficam em `config.json`:

```json
{
  "accounts": {
    "NOME_CURTO": "Nome completo da janela do Dofus"
  },
  "travelersBag": {
    "zap": {
      "click": [X, Y],
      "detect": { "pos": [X, Y], "color": "0xRRGGBB" }
    }
  }
}
```

### Alterar contas

Adicione ou edite entradas em `accounts`. Use `Win+c` para copiar o nome exato da janela:

```json
{
  "accounts": {
    "iop": "Bate-no-sigilo - Iop - 3.5.14.18 - Release",
    "eni": "Cura-no-sigilo - Eniripsa - 3.5.14.18 - Release",
    "nova": "Nome da Janela - Classe - Versao - Release"
  }
}
```

Depois adicione o hotkey em `index.ahk`:

```ahk
$#5:: app.account.focus('nova')
```

### Alterar coordenadas de clique

`click` = onde o script clica para interagir com o elemento:

```json
"zap": {
  "click": [1165, 554]
}
```

Use `+KeyHistory` no AutoHotkey ou ferramentas do jogo para encontrar coordenadas.

### Alterar detecção de pixel

`detect.pos` = pixel que o script verifica para saber se a interface está aberta  
`detect.color` = cor esperada nesse pixel (formato `0xRRGGBB`)

```json
"zap": {
  "detect": { "pos": [1445, 429], "color": "0xA75F20" }
}
```

Para capturar cor e posição, use o script `src/utils/copy_pixel_color_and_position.ahk`

1. Execute o script via AutoHotkey V2
2. Posicione o mouse encima do pixel que deseja capturar a cor
3. Pressione a tecla `Alt Gr` (a tecla `Alt` do lado direito do teclado)

### Atualizar após patch do Dofus

Coordenadas e cores podem mudar após updates do jogo. Após cada patch:

1. Teste cada hotkey manualmente
2. Se falhar, recoloque as coordenadas com as ferramentas acima

## Requisitos

- Windows
- AutoHotkey v2.0
- Dofus.exe

## Notas

- Coordenadas de pixel são específicas para a versão do Dofus e podem precisar de ajuste após updates
- Testes manuais necessários para validar funcionamento
- Sem testes automatizados configurados
