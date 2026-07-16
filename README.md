# SIGAD

Sistema Integrado de Gestão Acadêmica e Departamental desenvolvido em Flutter.

O projeto oferece uma experiência responsiva para perfis institucionais (docência, coordenação, chefia e apoio administrativo), com módulos para carga docente, demandas, quadro de tarefas, laboratórios, calendário, anotações, atividades, relatórios e configurações.

## Tecnologias

- Flutter (Material 3)
- Dart
- Provider (estado de contexto de usuário)

## Pré-requisitos

- Flutter SDK instalado e configurado no PATH
- Dart SDK (incluído no Flutter)
- Dispositivo/emulador Android, iOS, Linux, macOS, Windows ou Chrome

## Como executar

1. Instale as dependências:

```bash
flutter pub get
```

2. Rode a aplicação:

```bash
flutter run
```

3. Para web:

```bash
flutter run -d chrome
```

4. Para executar os repositórios que já possuem adaptador remoto:

```bash
flutter run --dart-define=SIGAD_DATA_SOURCE=remote --dart-define=SIGAD_API_BASE_URL=https://api.sigad.local
```

## Qualidade

Validação estática:

```bash
flutter analyze
```

Testes:

```bash
flutter test
```

Marcadores de suite recomendados:

```bash
flutter test test/core
flutter test test/*repository*test.dart
flutter test test/*widget_test.dart
```

Cobertura focada (exemplo):

```bash
flutter test --coverage test/sprint1_flows_test.dart test/bate_papo_page_widget_test.dart test/configuracoes_page_widget_test.dart test/dashboard_page_widget_test.dart
```

## Fluxo de desenvolvimento recomendado

1. Implementar alteracoes seguindo a estrutura por feature (`domain`, `data`, `presentation`)
2. Rodar analise estatica (`flutter analyze`)
3. Executar testes focados da feature e testes de regressao
4. Validar cobertura dos cenarios criticos
5. Gerar commit pequeno com escopo unico

## Padrao de arquitetura por feature

- `domain`: entidades, regras de negocio e servicos puros
- `data`: repositorios e adaptadores de persistencia
- `presentation`: paginas e widgets de interface

Evitar acesso direto a persistencia em `presentation`; centralizar serializacao em `data`.

## Estrutura principal

- `lib/app`: roteamento, tema e bootstrap da aplicação
- `lib/core`: modelos compartilhados, navegação e serviços base
- `lib/features`: módulos funcionais por domínio
- `lib/shared`: componentes e widgets reutilizáveis

Arquitetura e operação detalhadas:

- `ARCHITECTURE_AND_OPERATIONS.md`
- `DOCUMENTACAO_APP.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `RELEASE_PLAYBOOK.md`
- `OPERATIONS_ENV_CHECKLIST.md`

## Funcionalidades implementadas

- Acesso demonstrativo local em `dev`, `test` e `staging`; produção falha fechada enquanto não houver autenticação institucional
- Navegação responsiva com menu lateral/drawer
- Dashboard por perfil
- Carga docente: cadastro pela chefia, catálogo de nomes/áreas do IFMA, regras EBTT/IFMA, conflitos de horário e redistribuição assistida
- Afinidade histórica auditável para desempatar sugestões com base nas decisões aceitas/rejeitadas
- Bate-papo local demonstrativo, sem entrega a outro usuário
- Demandas: criar, editar, excluir e filtrar
- Quadro de Tarefas: criar, mover por drag-and-drop e excluir cards
- Aulas práticas: gestão de slots e reservas por perfil
- Calendário e anotações locais
- Atividades: criar, editar, excluir e filtrar atividades
- Relatórios: visualização e filtros; exportação e compartilhamento aguardam servidor
- Configurações locais de perfil, tema e fonte

## Rotas do app

- `/login`
- `/`
- `/bate-papo`
- `/demandas`
- `/kanban`
- `/aulas-praticas`
- `/carga-docente`
- `/atividades`
- `/relatorios`
- `/configuracoes`
- `/calendario`
- `/notas`

## Limites atuais

- A persistência funcional atual usa armazenamento local do dispositivo; não há sincronização multiusuário.
- Autenticação institucional, envio de mensagens/convites, notificações, troca de email/senha, backup, reporte ao suporte, exportação e compartilhamento ainda dependem de backend.
- O acesso demonstrativo nunca é liberado quando `SIGAD_FLAVOR=prod`, mesmo que solicitado por outro define.
- A distribuição usa restrições determinísticas e uma afinidade estatística simples com suavização de Laplace. Ainda não existe um modelo de ML treinado externamente.
- Não há módulo de PIT; os documentos de PIT serviram apenas como referência de contexto.
- O projeto está preparado para evolução gradual com API e armazenamento remoto.
- O modo de dados pode alternar entre local/remoto via `--dart-define=SIGAD_DATA_SOURCE`.
- Sessão de usuário é persistida localmente com expiração e restauração na splash.
- Existe gate de qualidade em CI com formatação, camadas, `flutter analyze`, testes, goldens, bloqueio de demo em produção e cobertura mínima de 35%.

## Estado atual

- Protótipo local funcional com navegação responsiva, regras de negócio e persistência no dispositivo.
- Camadas `domain`, `data` e `presentation` separadas nas features principais.
- Contratos remotos iniciais disponíveis para demandas, atividades, Kanban e relatórios.
- Integrações institucionais e operação multiusuário continuam pendentes.

## Ambientes e Flavors

- `SIGAD_FLAVOR=dev|test|staging|prod` controla o ambiente de runtime.
- `SIGAD_ENABLE_DEMO_ACCESS=true|false` solicita acesso local, permitido apenas em `dev`, `test` e `staging`.
- Observabilidade remota pode ser ligada por define sem alterar codigo:
  - `SIGAD_OBSERVABILITY_ENABLED=true`
  - `SIGAD_OBSERVABILITY_ENDPOINT=https://seu-endpoint/events`

Exemplos:

```bash
flutter run --dart-define=SIGAD_FLAVOR=dev --dart-define=SIGAD_ENABLE_DEMO_ACCESS=true
flutter run --dart-define=SIGAD_FLAVOR=staging --dart-define=SIGAD_ENABLE_DEMO_ACCESS=true
flutter run --dart-define=SIGAD_FLAVOR=prod --dart-define=SIGAD_ENABLE_DEMO_ACCESS=false --dart-define=SIGAD_DATA_SOURCE=remote
```

Release Android (AAB):

```bash
flutter build appbundle --release --dart-define=SIGAD_FLAVOR=prod --dart-define=SIGAD_ENABLE_DEMO_ACCESS=false
```

## Checklist de release

1. Rodar `flutter analyze` e `flutter test`.
2. Validar flavor alvo (`dev/staging/prod`) e `dart-define` de ambiente.
3. Confirmar endpoint de observabilidade em producao.
4. Revisar permissoes e dados sensiveis (logs/token/sessao).
5. Gerar build assinado e executar smoke test em dispositivo real.
