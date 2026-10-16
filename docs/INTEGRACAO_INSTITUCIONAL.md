# SIGAD — integração institucional e agenda compartilhada

## Situação

O aplicativo possui um **contrato de integração preparado no cliente** e
um backend FastAPI/PostgreSQL com rotas de autenticação e agenda implementadas
no diretório [backend](../backend/README.md). **O serviço não está implantado
nem homologado no IFMA**. A integração real do SSO continua dependente de
autorização, cadastro do cliente OIDC e deploy.
Nenhum usuário deve informar sua senha institucional em formulários locais.

## Autenticação (SSO)

1. A TI institucional configura um provedor OpenID Connect autorizado e um
   cliente público usando Authorization Code + PKCE (nunca implicit flow).
2. A implementação de autenticação da plataforma obtém um access token
   validado pelo servidor e o entrega a `UserContextProvider.loginInstitutional(token)`.
3. O SIGAD consulta **GET /auth/me** com `Authorization: Bearer <token>`.
   O servidor valida assinatura, issuer, audience, prazo, identidade e permissões;
   o cliente não decide seu próprio perfil.
4. Resposta esperada:

```json
{
  "id": "identificador-institucional",
  "name": "Nome validado",
  "email": "docente@ifma.edu.br",
  "role": "professor",
  "expiresAt": "2026-10-16T12:00:00Z"
}
```

Papéis permitidos: `professor`, `coordenador`,
`servidorAdministrativo`, `chefeDepartamento`.

O cliente mantém o token somente em memória e não restaura sessão remota
a partir de preferências locais. `refreshSession()` revalida no servidor,
não inventa prorrogação. É necessário concluir o fluxo PKCE autorizado,
o ciclo de renovação segura e o logout do provedor antes do uso em produção.
O backend precisa impor autorizações em **cada** endpoint, sem confiar no papel
escolhido ou em nomes informados pelo aplicativo.

## Entrada institucional no Android e no iOS (Authorization Code + PKCE)

O aplicativo possui agora uma integração nativa com AppAuth. No modo remoto
exibe **Entrar com conta institucional** somente quando a configuração pública
é completa e a plataforma é compatível; caso contrário, o botão fica
desabilitado e nenhuma senha é solicitada no próprio SIGAD.

A TI institucional deve cadastrar um **cliente público (sem client secret)**
e verificar o suporte a OAuth 2.0 Authorization Code com PKCE S256.
O identificador de aplicativo Android atual ainda é provisório
(`com.example.sigad`) e **deve ser aprovado/substituído antes da produção**.

| Parâmetro Flutter via `--dart-define` | Significado |
|---|---|
| `SIGAD_DATA_SOURCE=remote` | Exige autenticação remota |
| `SIGAD_API_BASE_URL=https://...` | Backend SIGAD implantado |
| `SIGAD_OIDC_ISSUER=https://...` | URL HTTPS do emissor oficial |
| `SIGAD_OIDC_CLIENT_ID=...` | Identificador público registrado pela TI |
| `SIGAD_OIDC_REDIRECT_URI=sigad-auth://callback` | Callback nativo **exato** |
| `SIGAD_OIDC_API_SCOPE=...` | Escopo definido pela TI que produz access token para o backend SIGAD |

O redirect `sigad-auth://callback` já está registrado no Android e no iOS.
O esquema deve ser **registrado e aprovado** pelo IdP institucional antes do
uso. Para alterá-lo, é necessário atualizar simultaneamente o código, o
`AndroidManifest`/`build.gradle.kts`, o `Info.plist`, os testes e o
cadastro no IdP. Não compartilhar identificadores de clientes ou callback
com outros aplicativos não relacionados, pois esquemas privados podem
ser interceptados; em produção, avaliar redirect App/Universal Links
verificados e proteção adicional contra interceptação.

O aplicativo solicita `openid`, `profile`, `email` e o escopo da API.
O IdP devolve um **access token para a API**, e nunca um ID token utilizado
como Bearer. O backend checa assinatura, `iss`, `aud`, `exp`, `iat`
e autorização provisionada, no `GET /auth/me`. Não há perfil selecionável
na entrada remota, nem token/refresh token salvo em SharedPreferences.
Ao encerrar a sessão no aplicativo o token de acesso é descartado.
**Logout federado completo e renovação de sessão pelo IdP exigem homologação
adicional**, pois dependem dos endpoints e das políticas oficiais.

Suporte nativo implementado para **Android 7+ e iOS 13+**; Web, Linux e
Windows permanecem sem login institucional nesta etapa.

## Reservas compartilhadas

Disponíveis somente com `SIGAD_DATA_SOURCE=remote`,
`SIGAD_API_BASE_URL=https://<servidor-institucional>` e sessão válida.
O modo local continua independente e serve a testes/demonstração.

### GET /laboratorios/reservas

Requer Bearer token válido e papel com permissão de consultar a agenda.

```json
{
  "revision": "rev-100",
  "items": [
    {
      "id": "RES-100", "professor": "Docente",
      "laboratorio": "Laboratório 8", "ano": 2026, "mes": 10,
      "semanaDoMes": 3, "diaSemana": "Qui",
      "turno": "matutino", "periodo": 1, "grupoId": "RES-100"
    }
  ]
}
```

### PUT /laboratorios/reservas

Requer autenticação e **permissão de editar**. O cliente envia a lista completa
e a revisão recebida no GET ou no PUT anterior:

```json
{ "expectedRevision": "rev-100", "items": [] }
```

O backend deve, em **uma única transação**:

- verificar autenticação, papéis, propriedade da reserva e situação do laboratório;
- verificar que `expectedRevision` é igual à revisão atual;
- validar todas as datas, períodos e conflitos da lista;
- impedir duplicidade de `laboratorio + ano + mes + semanaDoMes +
  diaSemana + turno + periodo` com restrição única transacional;
- aplicar as alterações e incrementar a revisão **atomicamente**;
- responder `200 {"revision":"rev-101"}` após o commit.

Rejeições: `401` não autenticado, `403` sem permissão, `409` ou `412`
revisão desatualizada/choque de horários, `5xx` erro de servidor.
Sem sucesso confirmado **não há gravação local substitutiva**. O aplicativo
reverte a alteração visual e recarrega a agenda quando possível.

**Importante:** comparar no cliente evita alguns erros, mas não substitui
controle concorrente no banco. A garantia de que dois usuários não reservam
o mesmo horário somente existe quando o servidor implementar as transações
e restrições acima.

## Verificação de prontidão do servidor

A rota `GET /ready` agora verifica a configuração **local** do IdP e as
tabelas/revisão PostgreSQL, retornando 503 sem divulgar dados internos
quando essas dependências faltam. `GET /health` continua limitado à
disponibilidade do processo HTTP. A prontidão não valida a confiança na
chave JWKS nem substitui teste real de login com a TI.

Veja [o roteiro de homologação](HOMOLOGACAO_INSTITUCIONAL.md), incluindo
a compilação iOS de simulador, teste entre dispositivos e bloqueadores
atuais de publicação.

## Checklist de implantação

- Cadastrar o SIGAD no IdP do IFMA; configurar redirect URI e PKCE nas
  plataformas Flutter aprovadas pela instituição.
- Homologar `/auth/me` e a autorização do backend; a implementação está no repositório.
- Implantar GET/PUT já implementados, com revisão atômica e restrição única no banco.
- Provisionar HTTPS real, monitoramento, backups, auditoria e políticas LGPD.
- Testar dois dispositivos concorrentes (um deve receber 409/412),
  falhas offline e sessão expirada.
- Não distribuir como sistema acadêmico institucional até homologação.
