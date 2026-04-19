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

## Funcionalidades implementadas

- Autenticação inicial e seleção de perfil
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

- Os fluxos de CRUD atuais são em memória (sem backend persistente).
- O projeto está preparado para evolução com API e armazenamento remoto.
- O modo de dados pode alternar entre local/remoto via `--dart-define=SIGAD_DATA_SOURCE`.
- Sessão de usuário é persistida localmente com expiração e restauração na splash.
- Existe gate de qualidade em CI com `flutter analyze`, `flutter test --coverage` e mínimo de 35%.

## Estado atual dos sprints

- Sprint 1: fluxos base e navegacao responsiva concluídos
- Sprint 2: extracao de camadas (`domain`/`data`) em features principais concluída
- Sprint 3: concluído (qualidade técnica, cobertura e governança)
- Sprint 4: concluído (integrações, sessão, observabilidade, resiliência e CI gate)
