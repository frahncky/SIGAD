# Backend de reservas do SIGAD

Serviço FastAPI + PostgreSQL para o contrato do aplicativo Flutter.
**Código executável, ainda não implantado/homologado no IFMA.**

## Capacidades implementadas

- `GET /auth/me`: valida JWT RS256 do emissor e público esperados via JWKS HTTPS.
  O perfil é lido exclusivamente da tabela de membros autorizados, não do token.
- `GET /laboratorios/reservas`: agenda compartilhada + revisão consistente.
- `PUT /laboratorios/reservas`: grava lista completa **somente se**
  `expectedRevision` coincidir; transação serializada por `FOR UPDATE`.
- Índice UNIQUE de horário no PostgreSQL; rejeição de sobreposição,
  horários inválidos, laboratórios não provisionados ou não operantes.
- Ações sobre reservas de terceiros negadas a docentes/coordenação; a chefia
  pode editar/excluir reservas existentes. Todos criam reservas para si.
- `401` token inválido/ausente; `403` perfil sem autorização;
  `409` revisão, disponibilidade ou conflitos; `422` dados inválidos.
- Falhas não são gravadas localmente nem promovidas a sucesso.

## Executar em desenvolvimento

Python 3.12+ e PostgreSQL 17. Nunca usar dados reais sem homologação.

1. `cd backend` e `cp .env.example .env`; preencher apenas com configuração
   de desenvolvimento aprovada, **fora do versionamento**.
2. Definir `SIGAD_DB_PASSWORD` como variável de ambiente (mesma senha
   informada no `SIGAD_DATABASE_URL` dentro do arquivo `.env`).
3. `docker compose up -d db`.
4. Aplicar a migração **antes** de iniciar o serviço:

   ```sh
   docker compose exec -T db psql -U sigad -d sigad -v ON_ERROR_STOP=1 < migrations/001_initial.sql
   ```

5. Provisionar manualmente membros e laboratórios em banco de **teste**,
   de acordo com a autorização da instituição:

   ```sql
   INSERT INTO sigad_members (subject, role, active)
     VALUES ('SUB_OIDC_VERIFICADO', 'professor', true);
   INSERT INTO sigad_laboratories (name, operational)
     VALUES ('LABORATORIO_AUTORIZADO', true);
   ```

6. `docker compose up -d --build api`.
7. `curl http://127.0.0.1:8000/health`.

O serviço escuta apenas em localhost no compose; em produção usar
proxy HTTPS confiável, rede privada do banco, backups, rastreamento de
alterações, políticas de retenção/LGPD, limitação de requisições e monitoração.

## Integração com o aplicativo

Configurar o Flutter com:
`--dart-define=SIGAD_DATA_SOURCE=remote` e
`--dart-define=SIGAD_API_BASE_URL=https://HOST_APROVADO`.

O servidor só aceita access tokens **JWT RS256** emitidos pelo IdP previsto:
`SIGAD_OIDC_ISSUER`, `SIGAD_OIDC_AUDIENCE` e
`SIGAD_OIDC_JWKS_URL`. Os três parâmetros são obrigatórios.
Não há senha padrão, rota de login por senha nem usuário com acesso
automático. Cada `sub` autorizado precisa estar na tabela
`sigad_members` com `active=true`.

O Flutter agora inclui **cliente nativo OIDC Authorization Code + PKCE**
para Android/iOS. A autenticação só fica habilitada após a configuração
oficial do cliente, do emissor, do escopo de API e da URI de retorno com
`--dart-define`. Veja [o cadastro do SSO](../docs/INTEGRACAO_INSTITUCIONAL.md).
**Ainda dependem do IFMA** o cadastro oficial no IdP, a implantação da API,
o provisionamento de membros/laboratórios e a homologação. Tokens JWT internos
gerados para testes não representam autenticação de usuários reais.

## Regras de concorrência

A linha `sigad_reservation_revision(id=1)` é bloqueada antes de comparar
`expectedRevision` e gravar qualquer reserva. Isso funciona entre múltiplas
instâncias do backend conectadas **ao mesmo PostgreSQL**. Outro escritor
com a mesma revisão recebe `409` sem qualquer gravação. Um GET bloqueia
a revisão para obter agenda e número consistentes.

A restrição única em `sigad_reservations_unique_slot` impede que um
laboratório tenha duas reservas no mesmo ano, mês, bloco semanal, dia,
turno e período. O conjunto de alterações é atômico.

O Flutter não deve tentar reexecutar automaticamente um PUT após timeout:
primeiro deve obter a agenda atual e exibir eventual conflito.

## Testar contra PostgreSQL isolado

```sh
pip install -r backend/requirements-dev.txt
# Criar banco EXCLUSIVO sigad_test; aplicar backend/migrations/001_initial.sql
export PYTHONPATH=backend
export SIGAD_DATABASE_URL='postgresql+psycopg://sigad_test:sigad_test@127.0.0.1:5432/sigad_test'
ruff check backend/sigad_api backend/tests
pytest -q backend/tests
```

O teste faz TRUNCATE, por isso valida o sufixo exato `/sigad_test`.
O fluxo automatizado está em `.github/workflows/backend-ci.yml`,
com um PostgreSQL efêmero.

## Pendências para produção

- Cadastro e homologação do cliente móvel OIDC+PKCE no IdP institucional,
  configuração do fluxo de logout/renovação (sem versionar credenciais).
- Confirmação oficial das permissões propostas e provisionamento de membros.
- Cadastro verificado dos laboratórios, manutenção e políticas de reserva.
- Backup, migrações operacionais, auditoria persistente, rate limiting,
  observabilidade sem dados pessoais e revisão LGPD.
- Testes de homologação entre aparelhos em infraestrutura institucional.

Não afirmar que reservas entre dispositivos estejam ativas até implantação,
configuração e homologação.
