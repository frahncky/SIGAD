# Preparação de release Android

O applicationId institucional está **pendente de aprovação**. Nenhum identificador foi inventado. `com.example.sigad` permanece como fallback de desenvolvimento e namespace interno; builds release são bloqueados com esse fallback.

## Configuração

Defina `SIGAD_ANDROID_APPLICATION_ID` com o identificador aprovado. A propriedade Gradle `-PsigadApplicationId=...` tem precedência. Não reutilize um identificador de outra instituição/aplicativo. A escolha deve considerar cadastro na loja e configuração OIDC.

A assinatura release usa exclusivamente variáveis do ambiente:

| Variável | Conteúdo |
| --- | --- |
| `SIGAD_ANDROID_KEYSTORE_PATH` | Caminho do keystore institucional existente, preferencialmente absoluto e fora do repositório |
| `SIGAD_ANDROID_KEYSTORE_PASSWORD` | Senha do keystore |
| `SIGAD_ANDROID_KEY_ALIAS` | Alias da chave institucional |
| `SIGAD_ANDROID_KEY_PASSWORD` | Senha da chave |

Injete os valores pelo gerenciador de segredos da instituição/CI ou sessão local protegida. Não grave senhas em comandos versionados, arquivos do projeto, logs ou screenshots. Não há leitura de `key.properties`. Nenhuma chave foi criada por esta alteração.

## Verificação local

A partir de `android`, execute `./gradlew.bat :app:validateReleaseConfiguration`. A tarefa verifica presença e sintaxe do ID, campos de assinatura, existência do arquivo e rejeita o alias padrão/caminho padrão da chave debug. Também abre o keystore, valida senhas e alias de chave privada e verifica a correspondência entre chave e certificado por assinatura local em memória. Rejeita certificado com CN Android Debug, mesmo se arquivo e alias forem renomeados. Erros não incluem detalhes internos nem valores secretos. Isso não comprova titularidade institucional ou aprovação da chave; certificados arbitrários de teste continuam dependendo da validação institucional. Não houve teste com chave institucional real.

`preReleaseBuild` e `validateSigningRelease` dependem desta verificação. Sem configuração, o release falha com orientação; debug e sincronização Gradle permanecem disponíveis. A configuração release não faz fallback para assinatura debug. Não use `-x validateReleaseConfiguration` para produzir artefatos.

Após aprovação da identidade e fornecimento das credenciais, execute `flutter build appbundle --release` com a configuração de ambiente de produção aprovada. A geração do artefato não autoriza envio à loja. Validar também endpoints, OIDC, política de privacidade, declaração de dados, testes e assinatura do AAB antes da distribuição.

Referências: [assinatura Android](https://developer.android.com/studio/publish/app-signing), [variantes e proteção das senhas](https://developer.android.com/build/build-variants).
