# Zap Multi-Conta — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Permitir que o comando de zap seja executado em todas as contas abertas sequencialmente com um único atalho (`h`), usando SRP e DIP.

**Architecture:** Três classes com responsabilidades únicas: `AccountManager` (contas), `ZapNavigator` (UI), `ZapCoordinator` (orquestração). Dependências injetadas via construtor no `ZapCoordinator`.

**Tech Stack:** AutoHotkey v2.0

---

## File Structure

```
src/utils/
├── accounts.ahk         # Modify: Accounts → AccountManager
├── use_zap.ahk          # Modify: ZapNavigator.use() retorna Boolean
├── zap_coordinator.ahk # Create: ZapCoordinator
index.ahk                # Modify: DI + hotkey $h
```

---

## Task 1: AccountManager — Detectar contas abertas

**Files:**
- Modify: `src/utils/accounts.ahk`

- [ ] **Step 1: Renomear classe e atualizar construtor**

Substituir o conteúdo de `src/utils/accounts.ahk` por:

```ahk
#Requires AutoHotkey v2.0

class AccountManager {
    __New(accountList) {
        this.accountList := accountList
    }

    focus(accountName) {
        windowName := this.accountList.Get(accountName)
        ToolTip(accountName . '  ' . windowName)
        WinWait(windowName)
        WinActivate(windowName)
    }

    getOpenAccounts() {
        openAccounts := []
        for accountName, windowName in this.accountList {
            if WinExist(windowName) {
                openAccounts.Push(accountName)
            }
        }
        return openAccounts
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add src/utils/accounts.ahk
git commit -m "refactor: rename Accounts to AccountManager, add getOpenAccounts()"
```

---

## Task 2: ZapNavigator — use() retorna Boolean

**Files:**
- Modify: `src/utils/use_zap.ahk`

- [ ] **Step 1: Modificar método use() para retornar Boolean**

Substituir o método `use()` existente (linhas 64-93) por:

```ahk
    use() {
        if (this.destination = "") {
            destination := InputBox(
                "Para onde deseja viajar?",
                "Destino",
            )
            if (destination.result != "OK" or destination.value = "") {
                return false
            }
            this.destination := destination.value
        }

        this.running := true

        while (this.running) {
            isZapOpen := this.isZapInterfaceOpen
            isTravelOpen := this.isOnTravelScreen

            if (isZapOpen) {
                this.clickSearch()
                if (this.destination != "") {
                    Sleep(300)
                    Send(this.destination)
                    Sleep(300)
                    Send("{Enter}")
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
        return true
    }
```

- [ ] **Step 2: Commit**

```bash
git add src/utils/use_zap.ahk
git commit -m "feat: ZapNavigator.use() returns Boolean, skips InputBox if destination set"
```

---

## Task 3: ZapCoordinator — Orquestrar multi-conta

**Files:**
- Create: `src/utils/zap_coordinator.ahk`

- [ ] **Step 1: Criar ZapCoordinator**

Criar arquivo `src/utils/zap_coordinator.ahk`:

```ahk
#Requires AutoHotkey v2.0

class ZapCoordinator {
    __New(zapNav, accountMgr) {
        this.zapNav := zapNav
        this.accountMgr := accountMgr
    }

    runAll() {
        openAccounts := this.accountMgr.getOpenAccounts()

        if (openAccounts.Length = 0) {
            return
        }

        for accountName in openAccounts {
            this.accountMgr.focus(accountName)
            Sleep(200)

            if (!this.zapNav.use()) {
                return
            }
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add src/utils/zap_coordinator.ahk
git commit -m "feat: add ZapCoordinator with runAll() for multi-account zap"
```

---

## Task 4: index.ahk — Wire DI e hotkey

**Files:**
- Modify: `index.ahk`

- [ ] **Step 1: Atualizar includes e instâncias**

Substituir linhas 4-6 (includes) por:

```ahk
#Include ./src/utils/use_zap.ahk
#Include ./src/utils/accounts.ahk
#Include ./src/utils/zap_coordinator.ahk
#Include ./src/utils/copy_window_name.ahk
```

- [ ] **Step 2: Atualizar instanciação (após linha 40)**

Substituir linhas 39-40:

```ahk
acc := Accounts(config.accountList)
zap := ZapNavigator(config.sacoDeViagens)
```

Por:

```ahk
acc := AccountManager(config.accountList)
zapNav := ZapNavigator(config.sacoDeViagens)
coordinator := ZapCoordinator(zapNav, acc)
```

- [ ] **Step 3: Atualizar hotkey h**

Substituir linha 46:

```ahk
$h:: zap.use()
```

Por:

```ahk
$h:: coordinator.runAll()
```

- [ ] **Step 4: Commit**

```bash
git add index.ahk
git commit -m "feat: wire ZapCoordinator via DI, route $h to coordinator.runAll()"
```

---

## Self-Review Checklist

- [ ] `AccountManager.getOpenAccounts()` itera sobre `accountList` e usa `WinExist()`
- [ ] `ZapNavigator.use()` retorna `false` se InputBox cancelado, `true` se OK
- [ ] `ZapNavigator.use()` pula InputBox se `this.destination` já está preenchido
- [ ] `ZapCoordinator` recebe `zapNav` e `accountMgr` via construtor
- [ ] `ZapCoordinator.runAll()` itera contas abertas, passa `true`/`false` para abortar
- [ ] `index.ahk` instancia tudo via DI e hotkey `h` aponta para `coordinator.runAll()`
- [ ] Todos os commits com mensagens descritivas

---

Plan complete and saved to `docs/superpowers/plans/2026-05-10-zap-multi-account-plan.md`.

**Two execution options:**

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**