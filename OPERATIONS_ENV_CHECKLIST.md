# Checklist de Observabilidade e Seguranca por Ambiente

## Dev

Objetivo: velocidade de iteracao com seguranca basica.

### Observabilidade
- [ ] SIGAD_OBSERVABILITY_ENABLED=false por padrao local
- [ ] Logs com contexto tecnico e sem dados pessoais
- [ ] Eventos de erro reproduziveis com stack trace local

### Seguranca
- [ ] Sem credenciais reais em codigo, commits ou logs
- [ ] Dados de teste anonimizados
- [ ] Validacao de entrada em formularios e payloads

### Operacao
- [ ] flutter analyze sem erros
- [ ] flutter test verde

## Staging

Objetivo: homologacao fiel ao comportamento de producao.

### Observabilidade
- [ ] SIGAD_OBSERVABILITY_ENABLED=true
- [ ] SIGAD_OBSERVABILITY_ENDPOINT apontando para coletor de staging
- [ ] Correlacao de erros por fluxo (login, demandas, kanban, relatorios)

### Seguranca
- [ ] Tokens/segredos vindos apenas de secrets do ambiente
- [ ] Revisao de permissoes por role em fluxos criticos
- [ ] Revisao de logs para evitar PII

### Operacao
- [ ] Smoke test completo de modulos principais
- [ ] Teste de fallback local/remoto quando aplicavel
- [ ] Validacao manual de sessao (login/restore/logout/expiracao)

## Prod

Objetivo: estabilidade, rastreabilidade e conformidade.

### Observabilidade
- [ ] Endpoint de observabilidade de producao configurado
- [ ] Alarmes para aumento de erro por feature
- [ ] Monitoramento de taxa de falha em login e carga de dados

### Seguranca
- [ ] Segredos gerenciados por provedor seguro (nao em repositorio)
- [ ] Revisao final de superficies de autorizacao por role
- [ ] Politica de logs sem dados sensiveis habilitada

### Operacao
- [ ] Release validada com quality gate completo
- [ ] Build assinado e smoke test em dispositivo real
- [ ] Plano de rollback definido (tag/versao anterior)
- [ ] CHANGELOG atualizado e aprovado
