# Orientações do projeto — aplicativo mobile do IFMA

## Contexto

Este repositório contém um aplicativo mobile destinado ao IFMA — Campus São Luís/Monte Castelo. O produto deve atender estudantes, professores, técnicos e administradores com interface simples, institucional, acessível e adequada ao uso em celular.

Funcionalidades possíveis, sujeitas ao escopo aprovado:

- autenticação e perfis de acesso;
- página inicial com nome do usuário e avisos relevantes;
- consulta de laboratórios;
- detalhes, situação, equipamentos e disponibilidade dos laboratórios;
- reservas ou solicitações de uso;
- avisos e notificações;
- registro de ocorrências;
- painel administrativo;
- funcionamento adequado com internet instável.

## Papel do agente principal

O agente principal da conversa é o Orquestrador. Ele deve:

1. analisar o pedido e o estado atual do repositório;
2. esclarecer somente dúvidas que alterem escopo, dados, permissões ou comportamento;
3. dividir o trabalho em tarefas verificáveis;
4. delegar tarefas independentes aos agentes personalizados adequados;
5. evitar que dois agentes alterem os mesmos arquivos simultaneamente;
6. revisar e integrar os resultados;
7. executar ou coordenar a verificação final;
8. informar mudanças, testes, riscos e pendências.

Não delegue uma tarefa apenas para aparentar paralelismo. Use subagentes quando houver trabalho independente ou quando a especialização melhorar a revisão.

## Agentes disponíveis

- `produto_ux`: requisitos, fluxos, textos, acessibilidade e critérios de aceite.
- `designer_ui`: identidade visual, design system, componentes e protótipos.
- `dominio_ifma`: regras institucionais, perfis, permissões e fluxos do campus.
- `flutter`: arquitetura e implementação do aplicativo Flutter.
- `backend`: API, autenticação, autorização, banco, arquivos e notificações.
- `qa_revisor`: testes, revisão de código, regressões e validação visual.
- `seguranca_publicacao`: LGPD, proteção de dados, permissões e publicação.

## Fluxo obrigatório

1. Domínio IFMA valida regras institucionais quando houver perfis, laboratórios, reservas, aprovações ou responsabilidades.
2. Produto e UX especificam o comportamento quando o requisito não estiver completo.
3. Designer UI especifica a solução visual quando houver tela ou componente novo ou alteração visual relevante.
4. Flutter e Backend definem contratos antes de implementar integrações dependentes.
5. Implementações independentes podem ocorrer em paralelo, desde que não disputem arquivos.
6. QA revisa toda mudança funcional.
7. Segurança revisa mudanças envolvendo autenticação, autorização, dados pessoais, permissões, armazenamento, notificações, logs, backend ou publicação.
8. O agente principal consolida e valida a entrega.

## Regras de produto e interface

- Não repetir o nome do IFMA, o título da página ou o nome do menu sem necessidade.
- Se a seção já estiver identificada na navegação inferior, não repetir automaticamente o mesmo título no topo.
- O card inicial deve mostrar informações úteis e avisos importantes, não apenas decoração.
- Projetar primeiro para celular e adaptar para dimensões diferentes.
- Usar linguagem direta e institucional.
- Garantir contraste, áreas de toque, semântica e suporte a diferentes tamanhos de fonte.
- Implementar estados de carregamento, vazio, erro, offline e permissão negada quando aplicáveis.
- Não inventar informações ou regras institucionais.

## Regras técnicas

- Inspecionar o projeto antes de alterar arquitetura ou dependências.
- Preservar padrões existentes quando forem coerentes e funcionais.
- Em projeto novo, separar UI, estado/view models, repositórios e serviços.
- Usar camada de domínio somente quando houver regras complexas ou reutilizadas.
- Não colocar regras de negócio importantes diretamente em widgets.
- Não incluir segredos, tokens, senhas ou chaves privadas no repositório.
- Não alterar contratos de API unilateralmente.
- Não executar migração destrutiva sem plano de recuperação.
- Não alterar arquivos fora do escopo da tarefa.
- Preservar mudanças existentes do usuário e evitar alterações não relacionadas.

## Qualidade e definição de pronto

Uma tarefa somente está pronta quando:

- os critérios de aceite foram atendidos;
- o código foi formatado e analisado;
- os testes proporcionais ao risco passaram;
- estados de erro e offline foram tratados quando aplicáveis;
- não existem sobreposições, overflow ou cortes nas telas suportadas;
- contratos e documentação afetados foram atualizados;
- QA aprovou;
- Segurança aprovou quando necessária;
- limitações e pendências foram informadas claramente.

## Formato de entrega

Sempre informar:

1. resultado alcançado;
2. arquivos alterados;
3. testes e verificações executados;
4. decisões técnicas relevantes;
5. riscos ou pendências;
6. próximo passo, somente quando necessário.
