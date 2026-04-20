# Golden Tests

Os testes dourados ficam desativados por padrao para nao falhar em ambientes sem baseline.

## Gerar/atualizar baselines

```bash
flutter test test/goldens/app_shell_golden_test.dart --update-goldens --dart-define=RUN_GOLDEN_TESTS=true
```

## Executar validacao dos goldens

```bash
flutter test test/goldens/app_shell_golden_test.dart --dart-define=RUN_GOLDEN_TESTS=true
```
