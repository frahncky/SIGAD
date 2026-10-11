# SIGAD

Sistema Integrado de Gestão Acadêmica e Departamental desenvolvido em Flutter.

O projeto oferece uma experiência responsiva para perfis institucionais (como coordenação, chefia e apoio administrativo), com módulos para bate-papo, demandas, quadro de tarefas, laboratórios, agenda, atividades, relatórios e configurações.

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

4. Para executar com fonte remota (Sprint 4):

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

- Acesso demonstrativo local com seleção de perfil; autenticação institucional pendente
- Navegação responsiva com menu lateral/drawer
- Dashboard por perfil
- Bate-papo: conversas entre usuários por perfil
- Demandas: criar, editar, excluir e filtrar
- Quadro de Tarefas: criar, mover por drag-and-drop e excluir cards
- Aulas práticas: gestão de slots e reservas por perfil
- Agenda: criar, editar, excluir e filtrar compromissos
- Atividades: criar, editar, excluir e filtrar atividades
- Relatórios: visualização, download e compartilhamento com rastreio local
- Configurações: perfil, email, senha, backup, preferências e reporte de problema

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

## Observações

- Os fluxos locais usam persistência no dispositivo; não constituem um backend institucional compartilhado.
- O projeto está preparado para evolução com API e armazenamento remoto.
- O modo de dados pode alternar entre local/remoto via `--dart-define=SIGAD_DATA_SOURCE`.
- Somente sessões demonstrativas explícitas são persistidas localmente com expiração. Sessões antigas com token ou marcador são invalidadas; nenhuma credencial de API é restaurada.
- Existe gate de qualidade em CI com `flutter analyze`, `flutter test --coverage` e mínimo de 35%.

## Limites da demonstração e integração pendente

- O botão de demonstração só está disponível em build debug, com `SIGAD_FLAVOR=dev` e `SIGAD_DATA_SOURCE=local`. A entrada institucional informa que o serviço ainda não está integrado; não valida senha nem cria identidade simulada.
- Builds release, staging, prod e modo remoto não aceitam identidade demonstrativa. O perfil selecionado serve apenas à demonstração; os perfis efetivos deverão vir do servidor.
- `SIGAD_ENABLE_REMOTE_FALLBACK` agora é `false` por padrão. Em demandas, falhas de gravação remota sempre são propagadas, mesmo com fallback habilitado. O fallback opcional de leitura não implementa sincronização.
- O CRUD de demandas aguarda persistência antes de atualizar a lista e mostrar sucesso. Falhas mantêm o formulário e os dados anteriores; novas ações ficam bloqueadas durante a gravação.
- Reservas permanecem locais: concorrência entre dispositivos, idempotência e confirmação institucional dependem de um contrato de backend aprovado.
- As visões gerenciais do redesign permanecem reservadas, sem exibir os dados de exemplo como indicadores institucionais.
- Para integrar autenticação e reservas, são necessários o contrato da API, a origem dos perfis, a validade/renovação de sessão e a política de conflitos. Nenhum desses contratos foi inventado nesta correção.
## Estado atual dos sprints

- Sprint 1: fluxos base e navegacao responsiva concluídos
- Sprint 2: extracao de camadas (`domain`/`data`) em features principais concluída
- Sprint 3: concluído (qualidade técnica, cobertura e governança)
- Sprint 4: concluído (integrações, sessão, observabilidadeticas e refatoração responsiva)

## Ambientes e Flavors

- `SIGAD_FLAVOR=dev|staging|prod` controla o banner visual e tags de runtime.
- Android possui flavors nativos `dev`, `staging` e `prod`.
- Observabilidade remota pode ser ligada por define sem alterar codigo:
  - `SIGAD_OBSERVABILITY_ENABLED=true`
  - `SIGAD_OBSERVABILITY_ENDPOINT=https://seu-endpoint/events`

Exemplos:

```bash
flutter run --flavor dev --dart-define=SIGAD_FLAVOR=dev
flutter run --flavor staging --dart-define=SIGAD_FLAVOR=staging
flutter run --flavor prod --dart-define=SIGAD_FLAVOR=prod --dart-define=SIGAD_DATA_SOURCE=remote
```

Release Android (AAB):

```bash
flutter build appbundle --flavor prod --dart-define=SIGAD_FLAVOR=prod
```

## Checklist de release

1. Rodar `flutter analyze` e `flutter test`.
2. Validar flavor alvo (`dev/staging/prod`) e `dart-define` de ambiente.
3. Confirmar endpoint de observabilidade em producao.
4. Revisar permissoes e dados sensiveis (logs/token/sessao).
5. Gerar build assinado e executar smoke test em dispositivo real.
