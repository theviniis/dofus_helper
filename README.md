# Dofus AutoHotkey Scripts

Scripts de automação AutoHotkey v2.0 para o jogo **Dofus**, oferecendo troca de contas via hotkeys e viagem coordenada usando o item "Zap" (Saco de Viagens).

## Funcionalidades

- **Troca de conta:** `Win+1/2/3` foca nas contas iop/eni/sac
- **Zap multi-conta:** `h` inicia o Zap sequencialmente em todas as contas abertas
- **Detecção de UI:** Pixel-based detection para interface do jogo (sem dependências externas)
- **Cópia de informação:** `Win+C` copia o nome da janela atual

## Estrutura do Projeto

```
.
├── index.ahk                    # Entry point - hotkeys e configuração
├── src/utils/
│   ├── accounts.ahk              # Gerenciamento de contas (AccountManager)
│   ├── use_zap.ahk               # Navegação do Zap (ZapNavigator)
│   ├── zap_coordinator.ahk        # Orquestração multi-conta (ZapCoordinator)
│   ├── does_pixel_matches.ahk    # Utilitário de detecção de pixel
│   ├── copy_window_name.ahk     # Utilitário para copiar nome da janela
│   ├── copy_pixel_color_and_position.ahk
│   └── send_tooltip.ahk
├── docs/superpowers/             # Especificações e planos de implementação
└── .vscode/                      # Configurações do editor
```

## Como Usar

1. Instale o [AutoHotkey v2.0](https://www.autohotkey.com/)
2. Execute o script `index.ahk`
3. Use os atalhos no jogo Dofus

### Atalhos

| Atalho | Ação |
|--------|------|
| `Win+1` | Focar conta Iop |
| `Win+2` | Focar conta Eniripsa |
| `Win+3` | Focar conta Sacrier |
| `h` | Iniciar Zap em todas as contas abertas |
| `Esc` | Parar o loop do ZapNavigator |
| `Win+C` | Copiar nome da janela atual |

## Arquitetura

```
index.ahk (hotkeys + DI)
    ├── AccountManager (accounts.ahk)
    │       ├── focus(accountName) → WinActivate
    │       └── getOpenAccounts() → array de contas abertas
    │
    ├── ZapNavigator (use_zap.ahk)
    │       ├── isZapInterfaceOpen/isOnTravelScreen → pixel detection
    │       ├── use() → retorna Boolean (true=sucesso, false=cancelado)
    │       └── destination property → reutilizado entre contas
    │
    └── ZapCoordinator (zap_coordinator.ahk)
            ├── __New(zapNav, accountMgr) → injeção de dependência
            └── runAll() → orchestra zap multi-conta
```

**Fluxo de dados:** `h` → `ZapCoordinator.runAll()` → `AccountManager.getOpenAccounts()` → para cada: focus + `ZapNavigator.use()`. A primeira conta solicita destino via InputBox; contas subsequentes reutilizam o destino armazenado.

## Requisitos

- Windows
- AutoHotkey v2.0
- Dofus.exe

## Configuração

As coordenadas de pixel e nomes de janela estão em `index.ahk` no objeto `config`:

```ahk
config := {
    accountList: Map(
        'iop', 'Janela - Iop - X.X.X.X - Release',
        ...
    ),
    sacoDeViagens: {
        zap: { click: [x, y], detect: { pos: [x, y], color: 0xRRGGBB } },
        ...
    }
}
```

## Notas

- Coordenadas de pixel são específicas para a versão do Dofus e podem precisar de ajuste após updates
- Testes manuais necessários para validar funcionamento
- Sem testes automatizados configurados