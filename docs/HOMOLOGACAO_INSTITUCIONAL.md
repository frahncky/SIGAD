# SIGAD — plano de homologação institucional (pendências reais)

Este roteiro é para **ambiente de homologação**, não para iniciar uma
implantação automática nem liberar dados reais. A integração nativa Android/iOS
e o backend FastAPI/PostgreSQL estão no repositório; sua presença **não**
significa que os serviços do IFMA foram conectados ou homologados.

## 1. Responsabilidades e aprovações necessárias

Antes de qualquer acesso real, a TI/segurança institucional deve:

- Aprovar o domínio HTTPS, rede, certificados TLS, backup e banco PostgreSQL.
- Registrar o **cliente público OIDC** no IdP autorizado: fluxo Authorization
  Code + PKCE S256, sem client secret embarcado; redirect
  `sigad-auth://callback`, scopes e audiência para a API SIGAD.
- Fornecer o **issuer HTTPS**, client ID público, escopo da API, audiência e
  endpoint JWKS oficiais, sem incluir senhas, chaves ou tokens no Git.
- Homologar as regras de permissão propostas, o cadastro de docentes e a
  lista de laboratórios. Provisionamento ocorre no banco apenas por
  administradores autorizados.
- Validar base legal, minimização dos dados e políticas LGPD.
- Definir responsáveis por operação, incidentes, auditoria e desativação.

**Bloqueadores de distribuição:** o identificador Android é provisório
(`com.example.sigad`), há configuração de assinatura debug em release,
a URL real da API/IdP é desconhecida e o logout federado/renovação de sessão
ainda exigem validação. Nenhum desses bloqueadores é resolvido por um
`flutter build apk` bem-sucedido.

## 2. Servidor e saúde

O backend possui duas verificações distintas, sem autenticação:

| Rota | Significado |
| --- | --- |
| `GET /health` | O processo HTTP responde (liveness); não consulta dependências. |
| `GET /ready` | Configuração local do IdP preenchida e PostgreSQL com esquema e revisão inicial (readiness). |

`/ready` responde `200 {"status":"ready"}` quando as condições locais
forem satisfeitas ou `503` sem detalhes internos quando não estiverem.

**Uma resposta 200 em /ready não prova que o IdP/JWKS seja alcançável,
que o login real funcione, que usuários estejam autorizados ou que
a implantação esteja aprovada.**

No ambiente autorizado:

1. Aplicar a migração `backend/migrations/001_initial.sql` sob procedimento
   institucional controlado e backup.
2. Fornecer `SIGAD_DATABASE_URL`, `SIGAD_OIDC_ISSUER`,
   `SIGAD_OIDC_AUDIENCE` e `SIGAD_OIDC_JWKS_URL` por gerenciador de
   segredos da infraestrutura (jamais no app ou Git).
3. Provisionar papéis e laboratórios aprovados em
   `sigad_members` e `sigad_laboratories`.
4. Publicar a API **atrás de HTTPS** e monitorar `/ready` para retirar a
   instância do balanceador quando a configuração local ou banco falhar.
5. Configurar backup/restauração, auditoria, limitação de requisições,
   retenção de dados e observabilidade sem conteúdo sensível.

## 3. Aplicativo

Passar os **parâmetros públicos** somente para builds autorizados:

```sh
flutter run --dart-define=SIGAD_DATA_SOURCE=remote \
  --dart-define=SIGAD_API_BASE_URL=https://API_APROVADA \
  --dart-define=SIGAD_OIDC_ISSUER=https://EMISSOR_APROVADO \
  --dart-define=SIGAD_OIDC_CLIENT_ID=CLIENTE_PUBLICO \
  --dart-define=SIGAD_OIDC_REDIRECT_URI=sigad-auth://callback \
  --dart-define=SIGAD_OIDC_API_SCOPE=ESCOPO_DA_API
```

Não tratar `--dart-define` como armazenamento seguro para segredos:
seus valores podem ser extraídos do aplicativo distribuído.

O pipeline Android compila um APK **debug** em modo remoto, sem integração
com um IdP real. O pipeline iOS compila um aplicativo de **simulador sem
assinatura**; não valida distribuição por TestFlight nem o retorno de
login em iPhone real. Somente o provedor oficial pode autorizar a entrada.

## 4. Critérios de aceite para homologação

1. Em dois aparelhos/contas institucionais permitidas, SSO abre no navegador
   do sistema e só permite entrada depois da resposta do backend `/auth/me`.
2. Perfil inválido, usuário desativado, token expirado, issuer/audience
   incorretos e ausência de rede são recusados com feedback, sem dados
   privados no log.
3. Dois usuários tentam reservar o mesmo período com a mesma revisão:
   **um sucesso, outro HTTP 409**. O perdedor recarrega a agenda.
4. Um docente não consegue alterar/excluir reservas de terceiros; chefia
   somente com permissão explícita. Laboratório em manutenção não recebe
   novas reservas.
5. Reinicialização do app exige autenticação novamente: o token de acesso
   institucional **não** fica persistido em preferências locais.
6. Confirmar políticas de logout no IdP, expiração, revogação e renovação
   de sessão com TI.
7. Validar Android real, iPhone real, acessibilidade e condições offline,
   além de backup/restauração e auditoria dos dados.

## 5. Checklist de liberação

- [ ] Autorizações de TI/gestão, segurança e LGPD registradas
- [ ] Client ID e callback formalmente cadastrados no IdP
- [ ] Domínios HTTPS, JWKS e audiência verificados com tokens reais
- [ ] Backend e PostgreSQL implantados e monitorados
- [ ] Usuários, perfis e laboratórios homologados
- [ ] Testes em dois dispositivos reais aprovados
- [ ] Identificadores e assinaturas de Android/iOS aprovados
- [ ] Backup, auditoria, política de incidentes e rollback testados
- [ ] Aprovação institucional para distribuição

**Rollback:** desabilitar novos acessos no IdP ou no gateway, retirar a
API do balanceador sem apagar o banco e restaurar apenas por plano
institucional aprovado; nunca substituir a agenda compartilhada por
dados locais silenciosamente.
