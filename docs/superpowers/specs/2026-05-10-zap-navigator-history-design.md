# SPEC: Sugestões de Histórico no InputBox do ZapNavigator

## Overview
Adicionar lista de sugestões baseadas nas últimas visitas ao InputBox do ZapNavigator, usando arquivo local para persistência.

## Design

### Arquitetura (SRP)

**ZapNavigator** (src/utils/use_zap.ahk)
- Responsável: navegação e interação com interface zap
- `getDestination()` - Exibe GUI com lista de sugestões

**HistoryManager** (src/utils/history_manager.ahk)
- Responsável: gerenciamento de histórico de destinos
- `load()` - Carrega histórico do arquivo JSON
- `save()` - Salva histórico no arquivo JSON
- `getAll()` - Retorna todas as sugestões
- `add(dest)` - Adiciona destino ao histórico

### Fluxo

1. `zap.use()` → `getDestination()` → HistoryManager carrega histórico
2. Exibe GUI customizada com ListBox + Edit
3. Usuário seleciona sugestão OU digita novo destino
4. Se novo destino → HistoryManager adiciona ao histórico

### Estrutura do arquivo `history.json` (criar na raiz do projeto)

```json
{
  "destinations": []
}
```

## Configuração

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| HistoryManager.limit | 10 | Máximo de sugestões |
| HistoryManager.filePath | "./history.json" | Arquivo do histórico |

## UI da GUI

| Elemento | Conteúdo |
|----------|----------|
| Title | "ZapNavigator - Destino" |
| Text | "Selecione ou digite o destino:" |
| ListBox | Últimas N visitas (mais recente primeiro) |
| Edit | Campo para digitar novo destino |
| Button OK | Confirmar seleção |
| Button Cancel | Cancelar |

## Comportamento

| Cenário | Resultado |
|---------|-----------|
| Usuário seleciona sugestão | Usa destino selecionado |
| Usuário digita novo destino | Usa destino digitado |
| Usuário cancela ou vazio | Abre searchBar sem texto |
| Destino já existe no histórico | Move para início (mais recente) |
| Limite atingido | Remove item mais antigo |

## Critérios de Aceitação

- [ ] HistoryManager é uma classe separada (SRP)
- [ ] Histórico persiste entre sessões (arquivo JSON)
- [ ] GUI exibe lista de sugestões + campo de texto
- [ ] Usuário pode digitar novo destino
- [ ] Novo destino é adicionado ao histórico
- [ ] Limite configurável via variável