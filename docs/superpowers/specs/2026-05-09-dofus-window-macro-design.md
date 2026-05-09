# Design: Macro AutoHotkey v2 para Focar Janelas Dofus

## Overview

Macro em AutoHotkey v2 que permite focar 4 janelas diferentes do jogo Dofus usando atalhos WIN+1, WIN+2, WIN+3 e WIN+4.

## Objetivos

- Alternar rapidamente entre 4 instâncias do Dofus
- Overrides atalhos padrão do Windows (WIN+1/2/3/4)
- Correspondência exacta pelo título da janela

## Arquitetura

### Componentes

| Componente | Descrição |
|------------|-----------|
| Script principal | Arquivo `.ahk` com 4 hotkeys |

### Configurações

- `SetTitleMatchMode "Exact"` - correspondência exacta do nome da janela
- Prefixo `$` em cada hotkey - override do hook do Windows

## Funcionalidades

### Hotkeys

| Hotkey | Ação |
|--------|------|
| WIN+1 | Focar janela "Bate-no-sigilo" |
| WIN+2 | Focar janela "Cura-no-sigilo" |
| WIN+3 | Focar janela "Berserker-no-sigilo" |
| WIN+4 | Focar janela "Arqueiro-no-sigilo" |

### Comportamento

- Se a janela não existir, não faz nada (silencioso)
- Funcional em qualquer contexto (não só com Dofus em primeiro plano)

## Código

```autohotkey
SetTitleMatchMode "Exact"

$#1::WinActivate "Bate-no-sigilo"
$#2::WinActivate "Cura-no-sigilo"
$#3::WinActivate "Berserker-no-sigilo"
$#4::WinActivate "Arqueiro-no-sigilo"
```

## Notas

- Requer AutoHotkey v2 instalado
- Os nomes das janelas devem corresponder exactamente ao título da janela
- Executar como Administrador se necessário para focus de janelas elevated