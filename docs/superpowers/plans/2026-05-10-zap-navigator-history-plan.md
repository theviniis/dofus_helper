# ZapNavigator History Suggestions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar lista de sugestões baseadas nas últimas visitas ao InputBox do ZapNavigator, usando arquivo local para persistência.

**Architecture:** Criar HistoryManager como classe separada (SRP) para gerenciar histórico em arquivo JSON. Modificar getDestination() do ZapNavigator para usar GUI customizada com ListBox + Edit.

**Tech Stack:** AutoHotkey v2.0

---

### Task 1: Criar HistoryManager

**Files:**
- Create: `src/utils/history_manager.ahk`

- [ ] **Step 1: Criar classe HistoryManager**

```autohotkey
#Requires AutoHotkey v2.0

class HistoryManager {
    static limit := 10
    static filePath := "./history.json"

    static load() {
        if !FileExist(this.filePath) {
            return []
        }
        try {
            jsonContent := FileRead(this.filePath)
            data := JSON.parse(jsonContent)
            return data.has("destinations") ? data.destinations : []
        } catch {
            return []
        }
    }

    static save(destinations) {
        jsonContent := JSON.stringify({ destinations: destinations })
        FileDelete(this.filePath)
        FileAppend(jsonContent, this.filePath)
    }

    static getAll() {
        return this.load()
    }

    static add(destination) {
        destinations := this.load()
        
        existingIndex := destinations.IndexOf(destination)
        if (existingIndex > 0) {
            destinations.RemoveAt(existingIndex)
        }
        
        if (existingIndex = 1) {
            return destinations
        }

        destinations.InsertAt(1, destination)

        if (destinations.Length > this.limit) {
            destinations.Pop()
        }

        this.save(destinations)
        return destinations
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add src/utils/history_manager.ahk
git commit -m "feat: add HistoryManager class for destination history"
```

---

### Task 2: Criar arquivo history.json inicial

**Files:**
- Create: `history.json`

- [ ] **Step 1: Criar history.json com estrutura inicial**

```json
{
  "destinations": []
}
```

- [ ] **Step 2: Commit**

```bash
git add history.json
git commit -m "feat: add initial history.json file"
```

---

### Task 3: Modificar ZapNavigator para usar HistoryManager e GUI customizada

**Files:**
- Modify: `src/utils/use_zap.ahk:1-10`
- Modify: `src/utils/use_zap.ahk:50-63`

- [ ] **Step 1: Adicionar include do HistoryManager e variável de instância**

No topo do arquivo, após o include existente:

```autohotkey
#Include history_manager.ahk
```

Na classe, adicionar:

```autohotkey
this.history := HistoryManager
```

- [ ] **Step 2: Substituir getDestination() pela versão com GUI**

```autohotkey
    getDestination() {
        if (this.destination != "") {
            return this.destination
        }

        destinations := this.history.getAll()
        suggestions := ""

        for dest in destinations {
            suggestions .= dest . "|"
        }

        gui := Gui("+AlwaysOnTop")
        gui.Title := "ZapNavigator - Destino"
        gui.Add("Text",, "Selecione ou digite o destino:")

        if (suggestions != "") {
            gui.Add("ListBox", "vSelectedDestination w300", suggestions)
            gui.Add("Edit", "vNewDestination w300")
        } else {
            gui.Add("Edit", "vNewDestination w300")
        }

        gui.Add("Button", "Default gSubmitDestination w80", "OK")
        gui.Add("Button", "w80", "Cancel").OnEvent("Click", (*) => gui.Destroy())

        selectedValue := ""

        SubmitDestination() {
            try {
                selectedValue := gui["SelectedDestination"].Value
            }
            selectedValue := gui["NewDestination"].Value
            gui.Destroy()
        }

        gui.OnEvent("Close", (*) => gui.Destroy())
        gui.Show()

        if (selectedValue != "") {
            this.destination := selectedValue
            this.history.add(selectedValue)
            return this.destination
        }

        return ""
    }
```

- [ ] **Step 3: Commit**

```bash
git add src/utils/use_zap.ahk
git commit -m "feat: integrate HistoryManager and custom GUI in ZapNavigator"
```

---

## Spec Coverage Check

- [x] HistoryManager é uma classe separada (SRP) - Task 1
- [x] Histórico persiste entre sessões (arquivo JSON) - Task 2
- [x] GUI exibe lista de sugestões + campo de texto - Task 3
- [x] Usuário pode digitar novo destino - Task 3
- [x] Novo destino é adicionado ao histórico - Task 3
- [x] Limite configurável via variável (HistoryManager.limit) - Task 1

---

## Execution

**Plan complete and saved to `docs/superpowers/plans/2026-05-10-zap-navigator-history-plan.md`. Two execution options:**

1. **Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

2. **Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**