# Como usar no VS Code com Codex e Claude Code

## Instalação no projeto

1. Descompacte este pacote.
2. Copie `AGENTS.md`, `CLAUDE.md` e as pastas ocultas `.codex` e `.claude` para a raiz do projeto Flutter.
3. Confirme que a estrutura ficou assim:

```text
seu-projeto/
├── AGENTS.md
├── CLAUDE.md
├── .codex/
│   └── agents/
├── .claude/
│   └── agents/
├── pubspec.yaml
└── lib/
```

No Windows, `.codex` e `.claude` podem aparecer como pastas ocultas. O VS Code normalmente as exibe no Explorer.

## Início no Codex

Abra a raiz do projeto no VS Code e inicie uma nova conversa na extensão Codex. Use:

> Analise este projeto. Atue como Orquestrador e use os agentes personalizados quando houver tarefas independentes. Primeiro apresente o estado atual, os riscos e o plano de desenvolvimento. Não altere arquivos ainda.

## Início no Claude Code

Abra uma nova conversa e use:

> Analise este projeto seguindo CLAUDE.md e AGENTS.md. Atue como Orquestrador e delegue aos agentes personalizados quando necessário. Primeiro apresente o estado atual, os riscos e o plano. Não altere arquivos ainda.

## Implementação de uma funcionalidade

Exemplo:

> Implemente a consulta e os detalhes dos laboratórios. Use dominio_ifma para validar regras, produto_ux para requisitos e estados, designer_ui para a solução visual, flutter para implementar, backend se houver contrato ou banco, qa_revisor para testar e seguranca_publicacao se a mudança envolver dados, autenticação ou permissões. Coordene tudo, integre os resultados e entregue a funcionalidade testada.

## Revisão de uma implementação existente

> Revise a funcionalidade de reservas. Delegue ao qa_revisor a análise de regressões e testes e ao seguranca_publicacao a revisão de autorização e dados. Não implemente correções antes de apresentar os achados.

## Correção completa

> Corrija os problemas encontrados na funcionalidade de reservas. Distribua tarefas independentes entre flutter e backend, depois execute qa_revisor e seguranca_publicacao. Não permita alterações simultâneas nos mesmos arquivos.

## Observações

- O agente principal da conversa funciona como Orquestrador nos dois assistentes.
- Os agentes especializados são acionados pelo agente principal.
- Abra uma nova conversa depois de copiar os arquivos, para que as orientações sejam carregadas desde o início.
- Se o projeto já possui `AGENTS.md`, mescle as regras; não substitua orientações existentes sem revisão.
- Se o projeto já possui `.codex/agents` ou `.claude/agents`, copie apenas os novos arquivos de agentes.
- Não deixe Codex e Claude modificarem os mesmos arquivos ao mesmo tempo.
