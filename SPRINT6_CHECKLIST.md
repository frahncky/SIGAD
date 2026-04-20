# SPRINT 6 - UX, Acessibilidade e Tema Escuro

Objetivo: consolidar a experiência visual no tema escuro e elevar acessibilidade dos fluxos principais.

## Backlog Priorizado

- [ ] P0 - Introduzir tokens semânticos de cor para tema (surface/container/onSurface/onContainer) e reduzir uso direto de `SigadColors` fixas
- [x] P0 - Migrar Home Shell para cores via `Theme.of(context).colorScheme` e `Theme.of(context).textTheme`
- [x] P0 - Corrigir superfícies claras fixas em Login (`_LoginPanel`, `_LoginBackground`) para respeitar dark mode
- [ ] P0 - Revisar contraste de textos secundários (`muted`) e estados selecionados em cards/listas
- [ ] P1 - Aplicar tooltips e semantics consistentes em ações críticas (filtro, fechar modal, criar item, mais ações)
- [ ] P1 - Trocar `GestureDetector` por `InkWell`/`IconButton` onde o elemento é clicável sem affordance/accessibility
- [ ] P1 - Atualizar componentes de Dashboard/Relatórios/Kanban/Aulas Práticas para fundos e bordas dinâmicas por tema
- [ ] P1 - Validar foco visível e ordem de navegação (teclado/leitor) nas telas principais
- [ ] P2 - Definir padrão de uso de cores por role sem quebrar contraste no dark mode
- [ ] P2 - Documentar guideline de UI acessível em `ARCHITECTURE_AND_OPERATIONS.md`

## Testes e Validação

- [x] Adicionar testes de widget para dark mode em: Login, Home Shell, Dashboard
- [ ] Adicionar testes de acessibilidade básica (semantics labels e tooltips em ícones críticos)
- [ ] Rodar `flutter test` completo sem regressões

## Critérios de Pronto

- [ ] Fluxos principais com tema escuro consistente (sem cartões/superfícies "claras" indevidas)
- [ ] Contraste mínimo aceitável em textos e elementos interativos
- [ ] Ações de ícone com tooltip/semantics onde aplicável
- [ ] Testes novos aprovados e suíte completa verde
