# Arquitetura e Operação - SIGAD

## Visão Arquitetural

O SIGAD segue separação por feature em camadas:

- `domain`: entidades e regras de negócio puras
- `data`: repositories e contratos de persistência/integracão
- `presentation`: páginas e widgets de interface

## Fonte de Dados (Local/Remoto)

A estratégia de dados é configurável em runtime via `dart-define`:

- `SIGAD_DATA_SOURCE=local` usa apenas storage local
- `SIGAD_DATA_SOURCE=remote` usa API remota com fallback local opcional
- `SIGAD_ENABLE_REMOTE_FALLBACK=true|false` controla fallback em falha remota

Configurações principais:

- `SIGAD_API_BASE_URL` em `lib/core/network/api_config.dart`
- `AppRuntimeConfig` em `lib/core/config/app_runtime_config.dart`

## Sessão e Autenticação

A autenticação institucional ainda não está integrada. A entrada normal não cria usuário a partir do email, senha ou perfil selecionado.

Somente a demonstração local em debug/dev permite sessão. Ela persiste dados do perfil demonstrativo, `sessionKind=demo` e `expiresAt`. Não persiste token nem fragmentos de credenciais. O token público do provider permanece nulo.

Sessões legadas com token ou hint são invalidadas. A restauração de demonstração é restrita ao mesmo ambiente local permitido, com expiração obrigatória. Rotas de módulos exigem sessão válida antes de montar o conteúdo.

Arquivos:

- `lib/core/config/app_runtime_config.dart`
- `lib/core/services/auth_session_repository.dart`
- `lib/core/services/user_context_provider.dart`
- `lib/main.dart`
- `lib/app/routes/app_router.dart`

A integração futura requer identidade e perfis confirmados pelo servidor, expiração/revogação, armazenamento adequado às credenciais e tratamento de sessão inválida. O estado local demonstrativo não autoriza uma API.
## Autorização por Role

A autorização de ações críticas é centralizada em:

- `lib/core/security/authorization_policy.dart`

Pontos críticos aplicados:

- CRUD de demandas
- acesso/ações de relatórios
- acesso a configurações

## Observabilidade e Saúde

Eventos e erros passam por `AppEventLogger`, que também alimenta métricas em memória:

- erros por feature
- eventos por fluxo
- total de ações e erros

Arquivos:

- `lib/core/services/app_event_logger.dart`
- `lib/core/services/app_health_service.dart`

Painel mínimo de saúde exibido em Configurações.

## Resiliência

O client HTTP tem:

- timeout por request
- correlação simples por `operationId`
- logs de sucesso/erro/timeout

Fallback remoto é desabilitado por padrão. Em demandas, o fallback opcional limita-se à leitura: gravações precisam de confirmação remota e não são convertidas em sucesso local. Falhas no cache após confirmação remota são registradas sem exigir repetição do commit. Não há fila de sincronização implementada.

## Operação e Qualidade

Pipeline de qualidade:

- `.github/workflows/quality-gate.yml`

Etapas:

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test --coverage`
4. gate mínimo de cobertura (35%)

## Comandos Operacionais

Execução local padrão:

```bash
flutter run
```

Execução remota:

```bash
flutter run --dart-define=SIGAD_DATA_SOURCE=remote --dart-define=SIGAD_API_BASE_URL=https://api.sigad.local
```

Validação local:

```bash
flutter analyze
flutter test
```
