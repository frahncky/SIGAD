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
   docker compose exec -T db psql -U sigad -d sigad -v ON_ERROR_STOP=1 < migrations/002_reservation_audit.sql
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

## Prontidão e CI iOS

- `GET /health` é apenas liveness (processo HTTP acessível).
- `GET /ready` exige parâmetros OIDC locais e tabelas/revisão PostgreSQL,
  retornando `503` sem detalhes internos se não estiver pronto.
- **`/ready = 200` não certifica o acesso ao IdP/JWKS nem a homologação
  institucional**; exige testes manuais de login e reserva com usuários reais.
- O fluxo `iOS auth build` valida o app no **simulador iOS sem assinatura**.
  Não habilita distribuição por App Store/TestFlight nem valida callback em
  iPhone físico.

Consulte o [plano de homologação](../docs/HOMOLOGACAO_INSTITUCIONAL.md)
para requisitos, critérios de aceite e rollback.

## Auditoria de reservas (migração 002)

Depois de aplicar `001_initial.sql`, executar obrigatoriamente
`002_reservation_audit.sql` **na ordem**. Para homologação, aplicar também
`003_operational_roles.sql` com os papéis provisionados pela TI. A migração acrescenta uma tabela
de eventos; não elimina reservas já cadastradas. A rota `/ready` exige
a nova tabela para impedir novas gravações com esquema desatualizado.

Cada criação, alteração ou exclusão gera um evento `CREATED`, `UPDATED`
ou `REMOVED` com horário do servidor, revisão, identificador da reserva,
`sub` institucional do responsável e do operador, e horário/laboratório
antes/depois. **Não** são duplicados nomes, e-mails, disciplinas, senhas
nem tokens no histórico. Tentativas inválidas, operações negadas,
revisões obsoletas e PUT sem mudanças **não** geram eventos.

Os eventos são inseridos na **mesma transação SQL** das reservas: um
conflito ou falha de persistência desfaz igualmente agenda e auditoria.
Um trigger rejeita `UPDATE` e `DELETE` dos eventos. Esse controle
não substitui auditoria externa ou backup imutável: o proprietário do
banco ou um superusuário consegue alterar triggers ou truncar a tabela.
A TI deve usar conta de migração separada da conta da API e restringir
na conta da API o acesso à auditoria a `INSERT` (e à sequência IDENTITY
conforme os privilégios SQL exigidos pelo ambiente). Consultas de
auditoria devem ficar restritas a operadores institucionais autorizados,
fora da API pública; não existe rota de auditoria acessível a usuários.

Os identificadores `sub` do IdP constituem dados pessoais
pseudonimizados e requerem prazo de retenção, controle de acesso e
procedimento de exclusão/restrição definidos formalmente pela TI/LGPD.
Não executar `TRUNCATE` no banco institucional; ele é usado
**somente** nos testes PostgreSQL efêmeros do GitHub Actions.

## Contas operacionais, backup e restauração (migração 003)

**Sem acesso ao IFMA:** estes arquivos só serão aplicados pela TI em
PostgreSQL dedicado, com autorização, controle de acesso, cópias externas
criptografadas, prazos de retenção e procedimento formal de mudança.

A migração `003_operational_roles.sql` **não cria usuários nem senhas**.
A TI deve criar e manter separadamente três identidades de banco:
proprietário/migrador (DDL), conta `app_role` (API), e conta
`backup_role` (leitura lógica); nenhuma das duas últimas deve ser owner,
superusuário, membro do papel migrador ou ter `CREATEDB`/`CREATEROLE`.

Exemplo **somente sintático** (trocar nomes após aprovação e provisionar
senhas via gerenciador de segredos da TI):

```sh
psql -X -v ON_ERROR_STOP=1 \
  -v app_role=PAPEL_DA_API \
  -v backup_role=PAPEL_DE_BACKUP \
  -f migrations/003_operational_roles.sql
```

Aplicar **após as migrações 001 e 002**, como proprietário autorizado,
usando uma janela de mudanças. A migração é transacional e idempotente
para os privilégios *explícitos* dessas duas contas nas tabelas SIGAD.
Revoga acessos `PUBLIC` às cinco tabelas de domínio. Antes de implantar,
a TI também precisa revogar privilégios herdados de *outros* papéis,
validar `search_path`, `CONNECT` à base e garantir que a API não seja
membro de roles administrativas. A conta da aplicação tem apenas:
leitura de membros/laboratórios/revisões, leitura/inserção/exclusão de
reservas, atualização da revisão e **inserção** de auditoria, com leitura
restrita das colunas `id`/`recorded_at` exigidas pelo `RETURNING`
do SQLAlchemy. Não pode consultar identificadores pessoais no log de
auditoria, alterar o cadastro, executar DDL ou remover eventos.
A conta de backup lê tabelas/estado da sequência, sem escritas.
O papel de migração deve permanecer separado da aplicação.

### Backup lógico sob custódia da TI

O script [`ops/backup_homologacao.sh`](ops/backup_homologacao.sh)
requer `SIGAD_ENVIRONMENT=homologacao`, `PGHOST`, `PGDATABASE`,
`PGUSER` (papel de backup), `PGSSLMODE=verify-full`,
`PGSSLROOTCERT` legível, `PGPASSFILE` restrito e um diretório
`SIGAD_BACKUP_DIRECTORY` **preexistente**, privado e fora do Git.
Usa `pg_dump --format=custom`, verifica o arquivo com `pg_restore --list`,
gera hash SHA-256 e falha sem criar arquivo final se o dump não concluir.
Nunca inclui senha em argumento de linha de comando.

```sh
# Somente host de homologação autorizado, acesso privado e CA aprovada.
export SIGAD_ENVIRONMENT=homologacao PGSSLMODE=verify-full
export PGHOST=HOST_DO_BANCO PGPORT=5432 PGDATABASE=BANCO_APROVADO
export PGUSER=PAPEL_DE_BACKUP
export PGSSLROOTCERT=/CAMINHO_SEGURO/ca.pem
export PGPASSFILE=/CAMINHO_SEGURO/pgpass
export SIGAD_BACKUP_DIRECTORY=/VOLUME_PRIVADO/backups
bash ops/backup_homologacao.sh
```

O hash verifica corrupção acidental, **não autenticidade**; proteger
o backup e manifesto com armazenamento criptografado e controle de acesso,
cópia externa imutável/WORM se aprovada, monitoramento e rotação.
Definir **RPO/RTO e retenção** com a TI/LGPD; `pg_dump` não oferece
recuperação ponto-no-tempo (PITR), portanto a TI deve avaliar WAL/PITR
como proteção adicional. Sem testes de restauração, não presumir que
backups estejam recuperáveis.

### Restauração de ensaio, nunca sobre a agenda atual

O script [`ops/restore_homologacao.sh`](ops/restore_homologacao.sh)
só aceita um **banco existente e vazio** cujo nome comece com
`sigad_restore_`, e exige confirmação textual e TLS verificado.
Recomenda-se cluster isolado, credenciais temporárias do responsável
pela restauração, sem aplicativos apontando para esse banco.

```sh
export SIGAD_ENVIRONMENT=homologacao PGSSLMODE=verify-full
export PGHOST=HOST_ISOLADO PGDATABASE=sigad_restore_ENSAIO
export PGUSER=PAPEL_RESTAURADOR
export PGSSLROOTCERT=/CAMINHO_SEGURO/ca.pem
export PGPASSFILE=/CAMINHO_SEGURO/pgpass
export SIGAD_RESTORE_TARGET="$PGDATABASE"
export SIGAD_RESTORE_CONFIRMATION=RESTAURAR_SOMENTE_EM_BANCO_VAZIO
bash ops/restore_homologacao.sh \
  /VOLUME_PRIVADO/backups/ARQUIVO.dump \
  /VOLUME_PRIVADO/backups/ARQUIVO.dump.sha256
```

O nome real do banco deve ser **minúsculo** (por exemplo,
`sigad_restore_ensaio`); o valor em maiúsculas acima é somente ilustrativo.
Antes de restaurar, validar origem, integridade, autorização e isolamento
dos dados pessoais. O comando usa `pg_restore --single-transaction
--exit-on-error --no-owner --no-acl`, verifica revisão/esquema e não
executa `DROP DATABASE` nem `--clean`. O papel restaurador é
privilegiado **somente naquele banco de ensaio**.
Os privilégios operacionais da origem **não** são reaplicados
(`--no-acl`); rodar `003_operational_roles.sql` com os novos papéis
de destino somente se necessário e aprovado. Em produção a TI deve
definir processo próprio, plano de parada, integridade e rollback.

O pipeline de CI também restaura um backup sintético gerado por uma
conta **somente leitura** em outro banco efêmero, verificando que
revisão, agenda e auditoria são preservadas. **Isso não é backup de dados
reais nem teste do ambiente institucional.**

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

## Ambiente de homologação: fail-closed

Além do Compose **local de desenvolvimento**, há agora
[`compose.homologacao.yaml`](compose.homologacao.yaml), que **não provisiona um
banco novo**: usa PostgreSQL externo autorizado, publica a API exclusivamente
em `127.0.0.1:8000`, executa com usuário não privilegiado, filesystem
somente leitura, capacidades Linux removidas e healthcheck em `/ready`.
Não disponibiliza HTTPS por conta própria: **proxy HTTPS e rede privada
precisam ser providos pela TI antes de acesso de outros dispositivos**.

1. Solicitar à TI a infraestrutura e os parâmetros **reais**; preencher
   um arquivo de configuração em local seguro **fora do repositório**, usando
   `.env.homologacao.example` só como referência, sem versionar senhas.
2. Manter o arquivo acessível apenas aos operadores (por exemplo,
   `chmod 600`). Garantir que `SIGAD_DATABASE_URL` use TLS PostgreSQL
   com `sslmode=verify-full` e uma CA confiável via `sslrootcert`.
   Se a CA for privada, provisioná-la no container com volume de leitura
   e controle de acesso aprovado pela TI; não copie chaves para o Git.
3. Aplicar `migrations/001_initial.sql`, `002_reservation_audit.sql` e
   `003_operational_roles.sql` (nessa ordem; a última com as variáveis de
   papéis criados pela TI), com backup anterior. O Compose **não executa
   migrações automaticamente**.
4. No host de homologação autorizado, usar:

   ```sh
   cd backend
   export SIGAD_HOMOLOGACAO_ENV_FILE=/CAMINHO_SEGURO/variaveis-homologacao.env
   docker compose -f compose.homologacao.yaml config --quiet
   docker compose -f compose.homologacao.yaml up -d --build
   curl --fail-with-body http://127.0.0.1:8000/health
   curl --fail-with-body http://127.0.0.1:8000/ready
   ```

A inicialização executa `python -m sigad_api.deployment_preflight` e **falha
sem iniciar** se ambiente, URLs HTTPS, banco PostgreSQL com autenticação,
TLS `verify-full` ou parâmetros OIDC necessários estiverem ausentes,
inseguros ou apontarem para domínios de exemplo. Logs do preflight contêm
somente nomes de variáveis e motivos genéricos, nunca seus valores. O
`/ready` valida a estrutura do banco, mas **não valida o servidor do IdP
nem substitui os testes reais de SSO**.

Não utilizar esta configuração diretamente na internet, em produção ou com
usuários reais antes das autorizações, proxy HTTPS, monitoramento, rate
limiting, políticas LGPD, auditoria e planos de backup e rollback da TI.

## Testar contra PostgreSQL isolado

```sh
pip install -r backend/requirements-dev.txt
# Criar banco EXCLUSIVO sigad_test; aplicar 001_initial.sql e 002_reservation_audit.sql
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
- Implantar as contas com privilégios mínimos e praticar backup/restauração
  de verdade na infraestrutura autorizada; rate limiting, observabilidade,
  retenção e revisão LGPD ainda dependem da TI.
- Testes de homologação entre aparelhos em infraestrutura institucional.

Não afirmar que reservas entre dispositivos estejam ativas até implantação,
configuração e homologação.
