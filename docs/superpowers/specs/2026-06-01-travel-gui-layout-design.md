# Design: Layout padrão do Gui de Travel

**Data:** 2026-06-01

## Objetivo

Padronizar o layout do diálogo `TravelNavigator` com dois GroupBoxes ("Destino" e "Opções"), campo Edit sem borda 3D recessed, e botões OK/Cancelar alinhados lado a lado no canto direito.

## Layout

```
┌─ Coordenadas ────────────────────────────────────┐
│ ┌─ Destino ──────────────────────────────────┐   │
│ │  Coordenadas (xx,yy):                      │   │
│ │  [________________________]  (-E0x200)     │   │
│ └────────────────────────────────────────────┘   │
│ ┌─ Opções ───────────────────────────────────┐   │
│ │  ☑ Focar personagem principal?             │   │
│ └────────────────────────────────────────────┘   │
│                          [Cancelar]    [OK]       │
└──────────────────────────────────────────────────┘
```

## Mudanças em `src/clients/travel.ahk`

### 1. Edit sem borda recessed

O campo de texto usa `-E0x200` para remover o estilo `WS_EX_CLIENTEDGE` (borda 3D sunken padrão do Windows):

```ahk
g.Add("Edit", "w200 vCoords -E0x200")
```

### 2. GroupBox "Destino"

Contém o Text label e o Edit de coordenadas. Largura do GroupBox: 240px, altura: 65px.

```ahk
g.Add("GroupBox", "w240 h65", "Destino")
g.Add("Text",, "Coordenadas (xx,yy):")
g.Add("Edit", "w220 vCoords -E0x200")
```

### 3. GroupBox "Opções"

Contém o CheckBox. Largura: 240px, altura: 40px.

```ahk
g.Add("GroupBox", "w240 h40", "Opções")
g.Add("CheckBox", "vFocusMain Checked", "Focar personagem principal?")
```

### 4. Botões alinhados à direita

GUI com largura 260px. Botões com 80px cada, margem direita de 10px e espaçamento de 10px entre eles. Cancelar à esquerda, OK à direita (Default):

- OK: `x = 260 - 10 - 80 = 170`
- Cancelar: `x = 170 - 10 - 80 = 80`

```ahk
g.Add("Button", "x80 w80", "Cancelar").OnEvent("Click", (*) => g.Destroy())
g.Add("Button", "x170 w80 Default", "OK").OnEvent("Click", OkClick)
```

## Restrições

- Apenas `src/clients/travel.ahk` é modificado
- Lógica de submit, validação, foco e envio do `/travel` permanecem inalterados
- Sem alteração em `init.ahk` ou `index.ahk`
