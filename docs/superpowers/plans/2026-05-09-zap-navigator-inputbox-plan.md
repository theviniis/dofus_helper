# Zap Navigator InputBox Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar InputBox para coletar destino do usuário ao pressionar `h`, com texto automaticamente colado na searchBar.

**Architecture:** Modificar classe `ZapNavigator` em `src/utils/use_zap.ahk` adicionando novo método `getDestination()` e alterando `use()` para exibir o InputBox e colar o destino.

**Tech Stack:** AutoHotkey v2.0

---

### Task 1: Adicionar método getDestination() à classe ZapNavigator

**Files:**
- Modify: `src/utils/use_zap.ahk:45-48` (adicionar novo método após o método `travel()`)

- [ ] **Step 1: Ler o arquivo atual para identificar ponto de inserção**

Ler `src/utils/use_zap.ahk` linhas 45-55 para ver a estrutura atual e onde o método `travel()` termina.

- [ ] **Step 2: Adicionar o método getDestination()**

Inserir após o método `travel()` (após linha 47):

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

- [ ] **Step 3: Commit**

```bash
git add src/utils/use_zap.ahk
git commit -m "feat: add getDestination method to ZapNavigator"
```

---

### Task 2: Modificar método use() para exibir InputBox e colar destino

**Files:**
- Modify: `src/utils/use_zap.ahk:49-71` (método `use()`)

- [ ] **Step 1: Ler o método use() atual**

Ler `src/utils/use_zap.ahk` linhas 49-71 para ver a implementação atual.

- [ ] **Step 2: Modificar a seção onde isZapOpen é verdadeiro**

No bloco `if (isZapOpen)`, substituir:
```autohotkey
if (isZapOpen) {
    this.clickSearch()
    break
}
```

Por:
```autohotkey
if (isZapOpen) {
    destination := this.getDestination()
    this.clickSearch()
    if (destination != "") {
        Sleep(300)
        Send(destination)
    }
    break
}
```

- [ ] **Step 3: Commit**

```bash
git add src/utils/use_zap.ahk
git commit -m "feat: modify use() to display InputBox and paste destination"
```

---

### Task 3: Testar manualmente a funcionalidade

**Files:**
- Test: `src/utils/use_zap.ahk`

- [ ] **Step 1: Executar o script AutoHotkey**

Executar o script que utiliza `ZapNavigator` para testar o comportamento:
- Pressionar `h` para acionar a funcionalidade
- Verificar se o InputBox aparece
- Testar os três cenários:
  1. Digitar destino e confirmar → texto deve ser colado na searchBar
  2. Cancelar InputBox → apenas abre a searchBar
  3. Deixar vazio e confirmar → apenas abre a searchBar

- [ ] **Step 4: Commit final**

```bash
git add docs/superpowers/specs/2026-05-09-zap-navigator-inputbox-design.md docs/superpowers/plans/2026-05-09-zap-navigator-inputbox-plan.md
git commit -m "docs: add spec and implementation plan for InputBox feature"
```

---

## Spec Coverage Check

| Requisito do Spec | Task |
|-------------------|------|
| Novo método `getDestination()` com InputBox | Task 1 |
| `use()` exibe InputBox quando Zap aberto | Task 2 |
| Texto colado automaticamente após clickSearch() | Task 2 |
| Cancelado/vazio abre searchBar sem texto | Task 2 |

**Status:** ✅ Todos os requisitos cobertos.