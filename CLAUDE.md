# Orientações para Claude Code

Leia e siga `AGENTS.md`, que contém o contexto, as regras técnicas, o fluxo de trabalho e a definição de pronto deste projeto.

O agente principal da conversa atua como Orquestrador. Delegue trabalho especializado aos agentes disponíveis em `.claude/agents/` somente quando isso melhorar a análise ou permitir tarefas independentes.

Não permita que dois agentes alterem os mesmos arquivos simultaneamente. Produto, design, domínio, QA e segurança devem atuar prioritariamente em análise e especificação. Flutter e Backend podem implementar apenas dentro de áreas de arquivos claramente separadas.

Depois da implementação, use `qa-revisor` e, quando houver dados, autenticação, autorização, permissões, notificações ou publicação, use `seguranca-publicacao`.

