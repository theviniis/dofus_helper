# Spec: Corrigir Estado de Destination no ZapNavigator

## Bug

Após executar `coordinator.runAll()`, a hotkey direta `zapNav.use()` reutiliza o último destino em vez de pedir novo input.

## Causa Raiz

- O `ZapCoordinator` e a hotkey `$h` compartilham a **mesma instância** de `ZapNavigator`
- O método `use()` (linha 51) só pede input se `this.destination = ""`
- Após `runAll()`, `destination` permanece populado, fazendo `use()` pular o prompt

## Solução

Adicionar parâmetro opcional `forceInput` ao método `use()`.

### Mudanças

**`src/utils/use_zap.ahk`**

```ahk
use(forceInput := false) {
    if (this.destination = "" || forceInput) {
        ; prompt user for destination
    }
}
```

**`src/utils/zap_coordinator.ahk`**

```ahk
this.zapNav.use(false)  ; reuse destination across accounts
```

**`index.ahk`**

```ahk
$h:: zapNav.use(true)  ; always prompt for destination
```

## Comportamento Resultante

| Chamada | destination Input |
|---------|-------------------|
| `coordinator.runAll()` | Pede uma vez, reutiliza |
| `zapNav.use()` (hotkey) | Sempre pede |

## Verificação

1. Executar `$+h` (coordinator) — deve pedir destino e viajar em todas contas
2. Executar `$h` — deve pedir novo destino (não reutilizar anterior)
3. Executar `$+h` novamente — deve reutilizar o destino do passo 1