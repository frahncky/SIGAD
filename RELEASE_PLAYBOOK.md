# Release Playbook (SIGAD)

## 1) Qualidade minima

```bash
flutter analyze
flutter test
```

## 2) Flavors e ambiente

### Dev

```bash
flutter run --flavor dev --dart-define=SIGAD_FLAVOR=dev --dart-define=SIGAD_DATA_SOURCE=local
```

### Staging

```bash
flutter run --flavor staging --dart-define=SIGAD_FLAVOR=staging --dart-define=SIGAD_DATA_SOURCE=remote
```

### Prod

```bash
flutter run --flavor prod --dart-define=SIGAD_FLAVOR=prod --dart-define=SIGAD_DATA_SOURCE=remote
```

## 3) Observabilidade

Ative somente em ambientes controlados:

```bash
--dart-define=SIGAD_OBSERVABILITY_ENABLED=true
--dart-define=SIGAD_OBSERVABILITY_ENDPOINT=https://seu-endpoint/events
```

Opcional para troubleshooting local:

```bash
--dart-define=SIGAD_VERBOSE_LOGS=true
```

## 4) Build para distribuicao

### Android (AAB)

```bash
flutter build appbundle --flavor prod --dart-define=SIGAD_FLAVOR=prod
```

### Android (APK)

```bash
flutter build apk --flavor prod --dart-define=SIGAD_FLAVOR=prod
```

## 5) Checklist de publicacao

1. Confirmar assinatura e credenciais do build release.
2. Revisar dados sensiveis em logs/eventos.
3. Validar login, logout, splash e restauracao de sessao.
4. Validar modulos criticos: Demandas, Kanban, Relatorios, Aulas praticas.
5. Fazer smoke test em dispositivo real.

## 6) Release automatizada

Existe workflow manual para release em:

- `.github/workflows/release.yml`

Entradas:

- `version` no formato `X.Y.Z`
- `release_notes` opcional

O workflow executa:

1. quality gate (format, analyze, test)
2. bump de versao no `pubspec.yaml`
3. preparacao de secao no `CHANGELOG.md`
4. commit e tag `vX.Y.Z`
5. build AAB
6. criacao de GitHub Release com artefato
