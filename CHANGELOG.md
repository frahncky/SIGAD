# Changelog

Todas as mudanças relevantes neste repositório serão documentadas neste arquivo.

## [v1.2.0] - 2026-04-25

### Alterado
- Módulo de Aulas Práticas: Refatoração completa da grade semanal para uso de layout flexível (`Expanded`), eliminando a necessidade de zoom e rolagem horizontal.
- Seletor de Dias: Alterado de lista de rolagem para layout em bloco (`Wrap`), permitindo visualizar todos os dias do mês de uma só vez.
- UI/UX: Otimização de tamanhos de fonte e densidade de células para melhor legibilidade em dispositivos móveis.
### Qualidade
- Validação de usabilidade para visualização direta de Segunda a Sexta sem interações complexas de gesto.

## [v1.1.0] - 2026-04-19

### Adicionado
- Checklist de execucao do Sprint 3 em `SPRINT3_CHECKLIST.md`.
- Testes de widget para Bate Papo, Configuracoes e Dashboard.
- Estrutura de dominio/dados para Bate Papo (`BatePapoService`, `BatePapoRepository` e `ConversationSummary`).
- Estrutura de dominio para perfil do Dashboard (`RoleProfile`, `RoleMetric`, `PriorityItem`).

### Alterado
- Dashboard passou a renderizar secao de prioridades dinamicas e chips de foco por perfil.
- Bate Papo passou a usar repositorio tambem para marcacao de leitura e envio tipado.
- Configuracoes recebeu restauracao de textos em PT-BR nos servicos e repositorio.
- README atualizado com fluxo recomendado de desenvolvimento, padrao de arquitetura por feature e comando de cobertura focada.

### Qualidade
- Consolidacao da validacao de sprint com testes de camada, fluxo e widget para features principais.

## [v1.0.0] - 2026-04-13

### Adicionado
- Estrutura inicial do app SIGAD com tela de login e navegação por perfil.
- Suporte a quatro perfis de usuário: Professor, Coordenador de Curso, Servidor Administrativo e Chefe de Departamento.
- Dashboard personalizado por perfil com indicadores, prioridades e atalhos.
- Shell responsivo com menu lateral em telas grandes e drawer em telas pequenas.
- Tema Material 3 customizado usando `GoogleFonts.spaceGrotesk`.
- Roteamento centralizado via `AppRouter` e gerenciamento de estado de usuário via `UserContextProvider`.

### Publicação
- Aplicação analisada com `flutter analyze` sem issues encontradas.
- Commit enviado para `main`.
- Tag de release criada: `v1.0.0`.
