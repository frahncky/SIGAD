# Release Playbook (SIGAD)

## 1) Qualidade minima

```bash
flutter analyze
flutter test
```

## 2) Flavors e ambiente

### Dev

```bash
flutter run --dart-define=SIGAD_FLAVOR=dev --dart-define=SIGAD_DATA_SOURCE=local
```

### Staging

```bash
flutter run --dart-define=SIGAD_FLAVOR=staging --dart-define=SIGAD_DATA_SOURCE=remote
```

### Prod

```bash
flutter run --dart-define=SIGAD_FLAVOR=prod --dart-define=SIGAD_DATA_SOURCE=remote
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

`SIGAD_FLAVOR` controla opções do aplicativo; não há `productFlavors` nativos.
O applicationId institucional está **pendente**. Antes de compilar release,
fornecer o identificador aprovado e a assinatura conforme
[ANDROID_RELEASE.md](docs/ANDROID_RELEASE.md). A configuração incompleta
bloqueia release, sem recorrer à chave debug. Não incluir senhas ou chaves no Git.
Login e backend também dependem da [homologação institucional](docs/HOMOLOGACAO_INSTITUCIONAL.md).

### Android (AAB)

```bash
flutter build appbundle --release --dart-define=SIGAD_FLAVOR=prod --dart-define=SIGAD_DATA_SOURCE=remote
```

### Android (APK)

```bash
flutter build apk --release --dart-define=SIGAD_FLAVOR=prod --dart-define=SIGAD_DATA_SOURCE=remote
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

1. validação de versão, identificador e segredos de assinatura;
2. quality gate (format, analyze, test);
3. bump de versão e preparação do changelog no checkout;
4. build AAB e upload do artefato;
5. commit, push e tag `vX.Y.Z`, somente após build bem-sucedido;
6. criação de GitHub Release com artefato e limpeza da chave temporária.

Configuração do repositório: variável `SIGAD_ANDROID_APPLICATION_ID`; secrets
`SIGAD_ANDROID_KEYSTORE_BASE64`, `SIGAD_ANDROID_KEYSTORE_PASSWORD`,
`SIGAD_ANDROID_KEY_ALIAS` e `SIGAD_ANDROID_KEY_PASSWORD`.
O arquivo de assinatura é reconstruído somente no diretório temporário do runner.
Nenhuma configuração ou execução remota foi realizada durante esta preparação.
O acionamento manual desse workflow publica alterações e artefatos e exige
autorização institucional para distribuição.
