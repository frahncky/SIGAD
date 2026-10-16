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

## Checklist de implantação

- Cadastrar o SIGAD no IdP do IFMA; configurar redirect URI e PKCE nas
  plataformas Flutter aprovadas pela instituição.
- Homologar `/auth/me` e a autorização do backend; a implementação está no repositório.
- Implantar GET/PUT já implementados, com revisão atômica e restrição única no banco.
- Provisionar HTTPS real, monitoramento, backups, auditoria e políticas LGPD.
- Testar dois dispositivos concorrentes (um deve receber 409/412),
  falhas offline e sessão expirada.
- Não distribuir como sistema acadêmico institucional até homologação.
