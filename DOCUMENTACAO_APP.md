# Documentacao do App SIGAD

## 1. Visao Geral

O SIGAD (Sistema Integrado de Gestao Academica e Departamental) e um aplicativo Flutter com foco em operacao academica por perfil de usuario.

O app concentra modulos de:
- dashboard
- bate-papo
- demandas
- quadro de tarefas (kanban)
- laboratorios (aulas praticas)
- agenda docente
- atividades
- relatorios
- configuracoes

## 2. Objetivo do Produto

Fornecer uma plataforma unica para planejamento, execucao e acompanhamento de rotinas academicas e administrativas, com navegacao adaptada por role e experiencia responsiva para desktop e mobile.

## 3. Tecnologias

- Flutter
- Dart
- Material 3
- Provider (estado)
- SharedPreferences (persistencia local)

## 4. Perfis de Usuario

Perfis suportados:
- professor
- coordenador
- servidor administrativo
- chefe de departamento

A navegacao e as acoes disponiveis variam por role. As regras centrais estao em:
- lib/core/security/authorization_policy.dart
- lib/core/navigation/navigation_items.dart

Documentacao complementar de roles:
- ROLES_AND_PERMISSIONS.md

## 5. Arquitetura

O projeto segue arquitetura por feature em 3 camadas:

- domain: entidades e regras de negocio puras
- data: repositorios, serializacao e integracao de dados
- presentation: paginas e widgets

Estrutura principal:
- lib/app: bootstrap, rotas e tema
- lib/core: modelos, servicos compartilhados, seguranca e navegacao
- lib/features: modulos funcionais
- lib/shared: componentes reutilizaveis

Referencia complementar:
- ARCHITECTURE_AND_OPERATIONS.md

## 6. Modulos Funcionais

### Dashboard
- visao inicial por perfil
- atalhos para modulos permitidos
- indicadores basicos

### Bate-papo
- listagem de conversas
- mensagens por contato
- marcacao de leitura
- modo demonstrativo local; nao entrega mensagens a outro usuario

### Demandas
- criar, editar, excluir e filtrar
- controle de permissao por role

### Kanban
- criar cards
- mover por coluna (drag-and-drop)
- excluir cards

### Laboratorios (Aulas Praticas)
- reservas por laboratorio, dia e periodo
- regras de alteracao por role

### Carga Docente
- cadastro de docentes pela chefia com nomes/areas de referencia do IFMA
- validacao de carga EBTT/IFMA, conflitos e redistribuicao assistida
- visibilidade por perfil

### Atividades
- CRUD de atividades
- filtros de status e busca

### Relatorios
- listagem e filtro
- exportacao e compartilhamento aguardam integracao institucional

### Configuracoes
- perfil, tema e tamanho de fonte locais
- email, senha, backup, notificacoes e suporte aguardam integracao institucional

## 7. Fluxo de Navegacao

Rotas principais:
- /login
- /
- /bate-papo
- /demandas
- /kanban
- /aulas-praticas
- /carga-docente
- /atividades
- /relatorios
- /configuracoes
- /calendario
- /notas

Roteamento:
- lib/app/routes/app_routes.dart
- lib/app/routes/app_router.dart

Shell responsivo:
- lib/features/home/presentation/pages/home_shell_page.dart

## 8. Sessao e Autenticacao

- login salva contexto de usuario
- sessao e restaurada no bootstrap
- sessao expirada exige novo login

Arquivos-chave:
- lib/core/services/user_context_provider.dart
- lib/core/services/auth_session_repository.dart

## 9. Fonte de Dados

Modo de dados em runtime via dart-define:
- SIGAD_DATA_SOURCE=local
- SIGAD_DATA_SOURCE=remote

Fallback remoto opcional:
- SIGAD_ENABLE_REMOTE_FALLBACK=true|false

Base URL remota:
- SIGAD_API_BASE_URL=https://api.sigad.local

## 10. Observabilidade e Logs

- eventos de acao e erro via AppEventLogger
- suporte a endpoint remoto de observabilidade

Defines relevantes:
- SIGAD_OBSERVABILITY_ENABLED=true|false
- SIGAD_OBSERVABILITY_ENDPOINT=https://seu-endpoint/events

## 11. Execucao do Projeto

Instalar dependencias:

```bash
flutter pub get
```

Rodar app:

```bash
flutter run
```

Rodar web:

```bash
flutter run -d chrome
```

Rodar com dados remotos:

```bash
flutter run --dart-define=SIGAD_DATA_SOURCE=remote --dart-define=SIGAD_API_BASE_URL=https://api.sigad.local
```

## 12. Qualidade e Testes

Analise estatica:

```bash
flutter analyze
```

Testes:

```bash
flutter test
```

Cobertura:

```bash
flutter test --coverage
```

## 13. Convencoes de Desenvolvimento

- manter regras de negocio em domain
- evitar acesso direto a persistencia na presentation
- centralizar serializacao e integracao em data
- manter commits pequenos e com escopo unico

## 14. Troubleshooting Rapido

### App nao inicia
- validar Flutter SDK e device/emulador
- executar flutter doctor

### Erro de dependencias
- executar flutter pub get
- se necessario, limpar cache: flutter clean

### Erros de role/permissao
- revisar AuthorizationPolicy
- revisar availableFor em navigation_items

### Erros de build
- rodar flutter analyze e corrigir problemas primeiro

## 15. Referencias do Repositorio

- README.md
- ARCHITECTURE_AND_OPERATIONS.md
- ROLES_AND_PERMISSIONS.md
- CHANGELOG.md
- RELEASE_PLAYBOOK.md
