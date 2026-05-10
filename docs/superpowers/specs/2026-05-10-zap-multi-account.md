# Zap Multi-Conta — Especificação

**Data:** 2026-05-10
**Status:** Aprovada

---

## Objetivo

Permitir que o comando de zap (via item "Saco de Viagens") seja executado em **todas as contas Dofus abertas**, sequencialmente, usando um único atalho (`h`).

---

## Comportamento Esperado

1. Usuário pressiona `h`
2. Sistema detecta quais contas estão abertas
3. Exibe InputBox **apenas na primeira conta aberta**
4. Usuário insere destino → todas as contas viajam para o mesmo destino
5. Se InputBox for cancelado → **nenhuma** conta viaja

---

## Princípios de Design

### Single Responsibility Principle (SRP)

Cada classe possui **uma única responsabilidade**:

| Classe | Responsabilidade |
|--------|------------------|
| `ZapNavigator` | Detectar estado da UI e interagir com a interface do zap |
| `AccountManager` | Detectar contas abertas e focar janelas |
| `ZapCoordinator` | Orquestrar o fluxo multi-conta |

### Dependency Inversion Principle (DIP)

`ZapCoordinator` depende de **abstrações** (`ZapNavigator`, `AccountManager`), não de detalhes concretos. As dependências são injetadas via construtor.

```
┌─────────────────┐     ┌──────────────────┐
│ ZapNavigator    │     │ AccountManager   │
│ (interface)     │     │ (interface)      │
└────────┬────────┘     └────────┬─────────┘
         │                       │
         └─────────┬─────────────┘
                   ▼
         ┌──────────────────┐
         │ ZapCoordinator    │
         │ (usa/abstrações)  │
         └──────────────────┘
```

---

## Arquitetura

### Classes

#### 1. `ZapNavigator` (`src/utils/use_zap.ahk`)

**Responsabilidade:** Navegação na interface do zap

**Métodos:**

| Método | Parâmetros | Retorno | Descrição |
|--------|------------|---------|-----------|
| `isOnTravelScreen` | — | `Boolean` | Detecta se tela de viagem está aberta |
| `isZapInterfaceOpen` | — | `Boolean` | Detecta se interface do zap está aberta |
| `clickZap` | — | `void` | Clica no botão de zap |
| `clickSearch` | — | `void` | Clica na barra de busca |
| `travel` | — | `void` | Envia comando `h` para acionar zap |
| `use` | — | `Boolean` | Executa fluxo de viagem. Retorna `true` se sucesso, `false` se cancelado |

**Propriedades:**

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `destination` | `String` | Destino atual (armazenado após InputBox) |

#### 2. `AccountManager` (`src/utils/accounts.ahk`)

**Responsabilidade:** Gerenciar foco e detecção de contas

**Métodos:**

| Método | Parâmetros | Retorno | Descrição |
|--------|------------|---------|-----------|
| `focus` | `accountName` | `void` | Foca janela da conta |
| `getOpenAccounts` | — | `Array<String>` | Retorna lista de contas abertas |

**Construtor:** Recebe `accountList` (Map de nomes → títulos de janela)

#### 3. `ZapCoordinator` (`src/utils/zap_coordinator.ahk`)

**Responsabilidade:** Orquestrar execução em múltiplas contas

**Métodos:**

| Método | Parâmetros | Retorno | Descrição |
|--------|------------|---------|-----------|
| `runAll` | — | `void` | Executa zap em todas as contas abertas |

**Construtor:** Recebe `ZapNavigator` e `AccountManager` (injeção de dependência)

---

## Fluxo de Execução

```
Usuário pressiona 'h'
        │
        ▼
ZapCoordinator.runAll()
        │
        ▼
AccountManager.getOpenAccounts() → ["iop", "sac"]
        │
        ├─► Conta "iop" (primeira)
        │       │
        │       ▼
        │   AccountManager.focus("iop")
        │   ZapNavigator.use() → InputBox aparece
        │       │
        │       ├── [Cancel] → return false (abort)
        │       │
        │       └── [OK "Bonta"]
        │               │
        │               ▼
        │           destination := "Bonta"
        │           ZapNavigator.destination := "Bonta"
        │           Loop de navegação executa
        │
        ├─► Conta "sac" (demais)
        │       │
        │       ▼
        │   AccountManager.focus("sac")
        │   ZapNavigator.use() → usa destination="Bonta"
        │   Loop de navegação executa (sem InputBox)
        │
        ▼
Fim
```

---

## Modificações por Arquivo

### `src/utils/accounts.ahk`

- Renomear classe `Accounts` → `AccountManager`
- Adicionar método `getOpenAccounts()`
- Construtor recebe `accountList` (Map)

### `src/utils/use_zap.ahk`

- `ZapNavigator.use()` retorna `Boolean`
  - `true`: viagem concluída com sucesso
  - `false`: InputBox cancelado pelo usuário
- Se `this.destination` já está preenchido, pula InputBox
- Após InputBox OK, armazena valor em `this.destination`

### `src/utils/zap_coordinator.ahk` (NOVA)

- Classe `ZapCoordinator`
- Construtor recebe `ZapNavigator` e `AccountManager`
- Método `runAll()` implementa fluxo multi-conta

### `index.ahk`

- Instanciação via injeção de dependência:
  ```ahk
  zapNav := ZapNavigator(config.sacoDeViagens)
  accountMgr := AccountManager(config.accountList)
  coordinator := ZapCoordinator(zapNav, accountMgr)
  ```
- Hotkey: `$h:: coordinator.runAll()`

---

## Casos de Borda

| Cenário | Comportamento |
|---------|---------------|
| Nenhuma conta aberta | Nada acontece |
| Apenas 1 conta aberta | Funciona como hoje (InputBox aparece) |
| InputBox cancelado | Aborta, nenhuma conta viaja |
| Conta não está aberta | Ignorada (não executa, não alerta) |
| Destino não encontrado | Comportamento padrão do Dofus (erro na UI) |

---

## Critérios de Aceitação

- [ ] `h` executa zap em todas as contas abertas sequencialmente
- [ ] InputBox aparece apenas na primeira conta aberta
- [ ] Cancelar InputBox aborta toda a operação
- [ ] Contas fechadas são ignoradas
- [ ] Classes seguem SRP (uma responsabilidade cada)
- [ ] `ZapCoordinator` recebe dependências via construtor (DIP)
- [ ] Hotkey `h` continua funcionando para uso single-account (mesmo fluxo)

---

## Arquivos Finais

```
src/utils/
├── use_zap.ahk          # ZapNavigator (detecção + interação UI)
├── accounts.ahk         # AccountManager (contas + foco)
├── zap_coordinator.ahk  # ZapCoordinator (orquestração) [NOVO]
├── does_pixel_matches.ahk
├── copy_window_name.ahk
├── copy_pixel_color_and_position.ahk
└── send_tooltip.ahk

index.ahk                 # Configuração + DI + Hotkeys
```