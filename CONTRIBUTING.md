# Contribuindo com o SIGAD

Obrigado por contribuir.

## Fluxo de contribuicao

1. Crie uma branch a partir de main.
2. Implemente mudancas pequenas e com escopo unico.
3. Garanta que o app compila e os testes passam.
4. Abra um Pull Request preenchendo o template.

## Convencao de branch

Sugestao:
- feat/nome-curto
- fix/nome-curto
- chore/nome-curto
- docs/nome-curto
- test/nome-curto

## Convencao de commit

Padrao recomendado:
- feat: nova funcionalidade
- fix: correcao de bug
- refactor: melhoria interna sem mudar comportamento esperado
- docs: alteracao de documentacao
- test: criacao/ajuste de testes
- chore: manutencao do projeto

Exemplo:
fix: corrige filtro de demandas por status

## Qualidade obrigatoria

Antes de abrir PR, execute:

1. flutter pub get
2. flutter format .
3. flutter analyze
4. flutter test

## Escopo de arquitetura

Siga o padrao por feature:
- domain: regras de negocio
- data: repositorios e serializacao
- presentation: paginas e widgets

Evite regra de negocio dentro de widgets.

## UI e acessibilidade

Checklist minimo:
- textos e acoes principais com labels claros
- icones de acao com tooltip
- navegacao coerente em desktop e mobile
- sem regressao visual em dark/light quando aplicavel

## Testes

Sempre adicionar/ajustar testes quando alterar regra de negocio.

Tipos recomendados:
- unit test para services/domain
- widget test para comportamento de tela

## Pull Request

Um bom PR deve:
- explicar problema e solucao
- listar impacto por modulo
- incluir evidencias de validacao
- ser pequeno o suficiente para revisao objetiva

## Politica de breaking change

Mudancas que alteram comportamento esperado devem:
- ser documentadas no CHANGELOG
- indicar plano de migracao quando aplicavel

## Duvidas

Consulte:
- README.md
- ARCHITECTURE_AND_OPERATIONS.md
- DOCUMENTACAO_APP.md
- RELEASE_PLAYBOOK.md
