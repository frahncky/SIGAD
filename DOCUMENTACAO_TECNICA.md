# Documentação Técnica do SIGAD

Este documento descreve a arquitetura, padrões e exemplos de uso do projeto SIGAD.

## Estrutura de Pastas
- `lib/app/` - Configuração principal do app, rotas, temas e widgets compartilhados.
- `lib/core/` - Serviços, provedores e configurações globais.
- `lib/features/` - Funcionalidades modulares do sistema.
- `lib/shared/` - Utilitários e componentes compartilhados.

## Padrões de Código
- Utilize `const` sempre que possível em widgets.
- Documente classes públicas e métodos principais.
- Centralize cores e temas em `app/theme`.
- Use widgets compartilhados de `app/widgets` para evitar duplicidade.

## Exemplo de Widget Compartilhado
```dart
import 'package:sigad/app/widgets/sigad_loading_indicator.dart';

// ...
Widget build(BuildContext context) {
  return const SigadLoadingIndicator();
}
```

## Testes
- Testes de widget em `test/`.
- Recomenda-se criar testes para rotas, temas e widgets reutilizáveis.

## Observabilidade
- Utilize `AppObservabilityService` para logs e monitoramento de erros.

## Contribuição
- Siga o guia em `CONTRIBUTING.md`.
- Mantenha o padrão de código e documentação.
