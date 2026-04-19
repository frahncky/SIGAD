# Sprint 4 - Checklist de Execucao

## Objetivo
Preparar o SIGAD para evolucao de produto com foco em integracao, observabilidade e confiabilidade operacional.

## Pilar 1 - Integracao e Contratos
- [x] Definir contratos de API por feature (demandas, kanban, relatorios, atividades)
- [x] Criar camada de client HTTP desacoplada no core
- [x] Introduzir adaptadores de repositorio para alternar local/remoto por configuracao
- [x] Padronizar DTOs e mapeamentos entre domain e data

## Pilar 2 - Autenticacao e Sessao
- [x] Evoluir UserContext para fluxo de sessao com expiracao
- [x] Definir estrategia de refresh token (ou reautenticacao)
- [ ] Mapear autorizacao por role em pontos criticos de acao
- [x] Cobrir cenarios de sessao expirada em testes de fluxo

## Pilar 3 - Observabilidade
- [x] Padronizar eventos de telemetria por feature
- [x] Adicionar correlacao basica de operacoes (request id/local op id)
- [x] Centralizar logging de erros nao tratados
- [ ] Definir painel minimo de saude (erros por feature e fluxo)

## Pilar 4 - Resiliencia e UX de Falhas
- [x] Implementar estados de erro/retry para carregamentos principais
- [x] Garantir feedback consistente para timeout/falha de rede
- [x] Adicionar fallback para dados parciais quando possivel
- [ ] Cobrir casos offline em fluxos prioritarios

## Pilar 5 - Qualidade Continua
- [x] Criar suite de testes por marcador (unit/widget/flow)
- [ ] Definir gate minimo de cobertura para PR
- [x] Adicionar pipeline CI com analyze + testes + cobertura
- [x] Consolidar guia de contribuicao tecnica no README

## Definicao de Pronto (DoD)
- [x] Contratos de API definidos e revisados
- [x] Fluxos criticos com tratamento de erro e retry
- [x] Telemetria basica ativa em features principais
- [x] CI validando analise e testes automaticamente
- [ ] Documentacao de arquitetura e operacao atualizada

## Sequencia Recomendada
1. Contratos e client base
2. Sessao/autenticacao
3. Resiliencia e estados de falha
4. Observabilidade
5. CI e gate de qualidade

## Progresso atual
- Camada HTTP base criada em `lib/core/network/` com request/response/error/client.
- Contratos de API com DTO e mapeamento criados para atividades, demandas, kanban e relatorios.
- Validado com `flutter analyze` e testes em `test/core/http_package_client_test.dart` e `test/contracts/api_contracts_test.dart`.
- Adaptadores local/remoto com fallback ativos para atividades, demandas, kanban e relatorios.
- Sessao persistente com expiracao, restauracao na splash e reautenticacao quando expirada.
- CI com gate de cobertura minima em `.github/workflows/quality-gate.yml`.
