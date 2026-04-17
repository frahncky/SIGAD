# SIGAD

Sistema Integrado de Gestão Acadêmica e Departamental desenvolvido em Flutter.

O projeto oferece uma experiência responsiva para perfis institucionais (como coordenação, chefia e apoio administrativo), com módulos para demandas, kanban, aulas práticas, carga docente, atividades, relatórios e configurações.

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

## Qualidade

Validação estática:

```bash
flutter analyze
```

Testes:

```bash
flutter test
```

## Estrutura principal

- `lib/app`: roteamento, tema e bootstrap da aplicação
- `lib/core`: modelos compartilhados, navegação e serviços base
- `lib/features`: módulos funcionais por domínio
- `lib/shared`: componentes e widgets reutilizáveis

## Funcionalidades implementadas

- Autenticação inicial e seleção de perfil
- Navegação responsiva com menu lateral/drawer
- Dashboard por perfil
- Demandas: criar, editar, excluir e filtrar
- Kanban: criar, mover por drag-and-drop e excluir cards
- Aulas práticas: gestão de slots e reservas por perfil
- Carga docente: criar, editar, excluir e filtrar docentes
- Atividades: criar, editar, excluir e filtrar atividades
- Relatórios: visualização, download e compartilhamento com rastreio local
- Configurações: perfil, email, senha, backup, preferências e reporte de problema

## Rotas do app

- `/login`
- `/`
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
