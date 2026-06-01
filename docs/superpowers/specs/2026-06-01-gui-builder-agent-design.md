# Design: Agente gui-builder

**Data:** 2026-06-01

## Objetivo

Criar um Claude Code sub-agente local (`gui-builder`) especializado em criar, alterar e auditar GUIs AHK v2.0 neste projeto, garantindo conformidade com os padrões visuais estabelecidos.

## Arquivo gerado

`.claude/agents/gui-builder.md`

## Identidade e escopo

- **Nome:** `gui-builder`
- **Descrição:** Invocado quando a tarefa envolve `Gui()`, `g.Add()`, layout de controles ou conformidade com os padrões visuais do projeto.
- **Ferramentas:** `Read`, `Edit`, `Write`, `Bash`
- **Escopo:** local (apenas este projeto)

## Modos de operação

| Modo | Trigger | O que faz |
|------|---------|-----------|
| Criar | "crie um GUI para X" | Gera bloco AHK completo a partir de descrição de campos/seções |
| Alterar | "adicione/mude X no GUI de Y" | Lê o arquivo, aplica mudança mantendo padrões |
| Auditar | "audite os GUIs de Z" | Lê arquivo e lista violações por regra |

## As 4 regras (hard constraints)

1. **Edit sem borda** — Todo controle `Edit` usa `-E0x200` (remove `WS_EX_CLIENTEDGE`).
2. **Ordem dos botões** — Cancelar sempre à esquerda do OK.
3. **Posição dos botões** — Lado a lado, canto inferior direito, calculado pela largura da GUI.
4. **GroupBox obrigatório** — Todo conjunto de controles fica dentro de um `GroupBox` nomeado.

## Constantes de espaçamento

```ahk
WIN_M  := 10  ; margem externa: janela → GroupBox
PAD    := 10  ; padding interno: GroupBox → controles
GB_HDR := 18  ; altura do título do GroupBox
C_GAP  := 16  ; gap vertical entre controles empilhados
GB_GAP := 7   ; gap vertical entre GroupBoxes
BTN_M  := 10  ; gap do último GroupBox até linha de botões
BTN_W  := 80  ; largura de cada botão
BTN_G  := 10  ; gap horizontal entre botões
```

Essas constantes são fixas. O agente as usa para calcular todas as coordenadas — nenhuma coordenada é hardcoded sem derivação das constantes.

## Template AHK v2.0

```ahk
; --- Spacing constants ---
WIN_M  := 10
PAD    := 10
GB_HDR := 18
C_GAP  := 16
GB_GAP := 7
BTN_M  := 10
BTN_W  := 80
BTN_G  := 10

W := 260  ; largura da GUI — ajustar por diálogo

; --- GroupBox 1 ---
gb1Y := WIN_M
g.Add("GroupBox", "x" WIN_M " y" gb1Y " w" (W - WIN_M*2) " h65", "Seção 1")
g.Add("Text",     "x" (WIN_M+PAD) " y" (gb1Y+GB_HDR),           "Label:")
g.Add("Edit",     "x" (WIN_M+PAD) " y" (gb1Y+GB_HDR+C_GAP) " w" (W-WIN_M*2-PAD*2) " vField -E0x200")

; --- GroupBox 2 ---
gb2Y := gb1Y + 65 + GB_GAP
g.Add("GroupBox", "x" WIN_M " y" gb2Y " w" (W - WIN_M*2) " h40", "Seção 2")
g.Add("CheckBox", "x" (WIN_M+PAD) " y" (gb2Y+GB_HDR) " vOpt Checked", "Opção?")

; --- Botões (canto inferior direito) ---
btnY    := gb2Y + 40 + BTN_M
okX     := W - WIN_M - BTN_W        ; ex: W=260 → okX=170
cancelX := okX - BTN_G - BTN_W     ; ex: W=260 → cancelX=80

g.Add("Button", "x" cancelX " y" btnY " w" BTN_W,            "Cancelar").OnEvent("Click", (*) => g.Destroy())
g.Add("Button", "x" okX     " y" btnY " w" BTN_W " Default", "OK").OnEvent("Click", OkClick)
```

### Cálculo do `h` dos GroupBoxes

| Conteúdo | Fórmula | Exemplo |
|----------|---------|---------|
| Label + Edit | `GB_HDR + 14 + C_GAP + 17` | 18+14+16+17 = 65 |
| Só CheckBox | `GB_HDR + 14 + PAD - 2` | 18+14+10-2 = 40 |
| Label + Edit + Label + Edit | `GB_HDR + 14 + C_GAP + 17 + C_GAP + 17` | 18+14+16+17+16+17 = 98 |

O agente calcula `h` somando os elementos reais — sem adivinhar.

## Checklist de auditoria

O agente verifica cada item ao auditar:

- [ ] Todo `Edit` tem `-E0x200`?
- [ ] Botão OK tem `Default`?
- [ ] `cancelX < okX`? (Cancel à esquerda)
- [ ] `okX = W - WIN_M - BTN_W`? (fórmula correta)
- [ ] Todo conjunto de controles está dentro de `GroupBox` nomeado?
- [ ] Espaçamentos derivados das constantes (sem hardcode arbitrário)?

## Arquivos com GUIs no projeto

| Arquivo | GUI | Status |
|---------|-----|--------|
| `src/clients/travel.ahk` | Diálogo de coordenadas | Conforme (usa coordenadas hardcoded derivadas dos padrões) |
| `src/clients/zap.ahk` | Seletor de destino + contas | Parcialmente conforme (`-E0x200` ok, botões usam `x+10` em vez da fórmula) |

## Restrições

- O agente não modifica lógica de negócio — apenas a parte de `Gui()` e `g.Add()`
- Não altera `config.json`, `index.ahk` (hotkeys) ou `init.ahk`
- Não cria novos arquivos `.ahk` — edita apenas arquivos existentes
- As constantes de espaçamento são variáveis locais dentro do método que constrói a GUI, não globais
