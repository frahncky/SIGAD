# Orientações do projeto — aplicativo mobile institucional

## 1. Contexto

Este repositório contém um aplicativo mobile institucional de gestão acadêmica e departamental.

O produto deve atender, conforme o escopo aprovado:

- estudantes;
- professores;
- técnicos;
- administradores;
- responsáveis institucionais autorizados.

O aplicativo deve ser:

- simples;
- institucional;
- acessível;
- responsivo;
- seguro;
- adequado ao uso em celular;
- funcional em condições de internet instável.

Funcionalidades possíveis, sujeitas à confirmação:

- autenticação;
- perfis e permissões;
- página inicial com informações e avisos relevantes;
- consulta de laboratórios;
- detalhes e situação dos laboratórios;
- equipamentos;
- disponibilidade;
- solicitações e reservas;
- aprovações e cancelamentos;
- notificações;
- ocorrências;
- painel administrativo;
- histórico e auditoria.

Uma funcionalidade possível não deve ser tratada como requisito confirmado sem aprovação.

## 2. Fontes e decisões

Não invente:

- regras institucionais;
- permissões;
- autoridades;
- fluxos administrativos;
- dados;
- normas;
- requisitos;
- contratos;
- informações sobre laboratórios.

Quando houver dúvida, classifique a informação como:

- confirmada;
- inferida;
- proposta;
- pendente;
- conflitante.

Inferências não devem ser implementadas como regras definitivas.

Quando documentos ou instruções entrarem em conflito, não escolha silenciosamente. Informe o conflito ao responsável pelo projeto.

## 3. Agente principal

O agente principal da conversa é o Orquestrador.

Ele deve:

1. analisar o pedido;
2. inspecionar o repositório;
3. identificar alterações preexistentes;
4. confirmar o resultado esperado;
5. separar o que está dentro e fora do escopo;
6. identificar dúvidas bloqueantes;
7. dividir o trabalho em tarefas verificáveis;
8. delegar aos agentes adequados;
9. controlar arquivos e áreas de responsabilidade;
10. integrar os resultados;
11. executar ou coordenar a verificação final;
12. informar mudanças, testes, riscos e pendências.

O Orquestrador é responsável pela decisão final de integração.

Resultados de subagentes são recomendações ou implementações parciais até serem revisados pelo agente principal.

## 4. Agentes disponíveis

### `dominio_institucional`

Use quando houver:

- perfis;
- permissões;
- laboratórios;
- equipamentos;
- reservas;
- aprovações;
- cancelamentos;
- ocorrências;
- responsabilidades;
- terminologia institucional.

### `produto_ux`

Use quando houver:

- requisito incompleto;
- fluxo novo;
- estados;
- conteúdo;
- mensagens;
- formulários;
- critérios de aceite;
- dúvida de usabilidade.

### `designer_ui`

Use quando houver:

- tela nova;
- alteração visual relevante;
- design system;
- componente;
- responsividade;
- acessibilidade visual;
- contraste;
- overflow;
- protótipo.

### `flutter`

Use para:

- arquitetura mobile;
- interface;
- gerenciamento de estado;
- navegação;
- integração;
- cache;
- funcionamento offline;
- correção de overflow;
- testes Flutter.

### `backend`

Use para:

- API;
- banco;
- autenticação;
- autorização;
- arquivos;
- notificações;
- reservas concorrentes;
- sincronização;
- auditoria;
- migrações.

### `qa_revisor`

Use após qualquer alteração funcional para:

- revisar código;
- executar testes;
- procurar regressões;
- verificar overflow;
- validar responsividade;
- verificar acessibilidade;
- emitir parecer.

### `seguranca_publicacao`

Use quando houver:

- autenticação;
- autorização;
- dados pessoais;
- armazenamento;
- permissões;
- notificações;
- logs;
- backend;
- dependências;
- configuração de produção;
- publicação.

## 5. Delegação

Não delegue apenas para aparentar paralelismo.

Use subagentes quando:

- as tarefas forem independentes;
- houver especialização relevante;
- a análise produzir muito contexto;
- uma revisão independente melhorar a qualidade.

Cada tarefa delegada deve informar:

- objetivo;
- contexto;
- arquivos ou áreas permitidas;
- itens fora do escopo;
- dependências;
- critérios de aceite;
- testes esperados;
- formato da entrega.

Subagentes devem devolver dúvidas ao Orquestrador. Não devem assumir decisões de produto ou institucionais.

## 6. Trabalho paralelo

Pode ocorrer em paralelo quando:

- os arquivos forem diferentes;
- os contratos estiverem definidos;
- as tarefas forem independentes;
- não houver migrações concorrentes.

Não pode ocorrer simultaneamente sem coordenação:

- alteração do mesmo arquivo;
- alteração da mesma rota;
- alteração do mesmo componente compartilhado;
- mudança de tema global;
- mudança de navegação;
- mudança do mesmo contrato;
- migrações sobre as mesmas tabelas;
- alterações concorrentes de configuração.

Cada arquivo deve possuir um único responsável ativo por vez.

Codex e Claude não devem modificar os mesmos arquivos simultaneamente.

## 7. Fluxos de trabalho

### Funcionalidade institucional nova

1. `dominio_institucional`;
2. `produto_ux`;
3. `designer_ui`;
4. contratos entre `flutter` e `backend`;
5. implementação;
6. `qa_revisor`;
7. `seguranca_publicacao`, quando aplicável;
8. validação do Orquestrador.

### Alteração apenas visual

1. `produto_ux`, se o comportamento não estiver claro;
2. `designer_ui`;
3. `flutter`;
4. `qa_revisor`.

### Correção de defeito

1. `qa_revisor` identifica e reproduz;
2. `flutter` ou `backend` corrige;
3. teste de regressão;
4. `qa_revisor` verifica novamente;
5. `seguranca_publicacao`, se a correção afetar segurança.

### Revisão sem implementação

Quando o pedido for analisar, diagnosticar ou revisar:

- não altere código;
- apresente evidências;
- classifique problemas;
- indique correções;
- aguarde autorização para implementar.

## 8. Produto e interface

- Não repetir o nome da instituição sem necessidade.
- Não repetir título já identificado na navegação.
- Não repetir o nome do menu no topo automaticamente.
- Usar a identidade institucional com equilíbrio.
- Preservar os ativos oficiais.
- Não distorcer ou recriar a logomarca.
- O card inicial deve mostrar informações úteis.
- Avisos devem possuir prioridade e validade.
- Projetar primeiro para celular.
- Usar linguagem direta e institucional.
- Não usar apenas cor para comunicar estados.
- Não truncar informação importante sem alternativa de leitura.
- Não usar placeholder como único rótulo.
- Toda ação deve fornecer feedback.
- Ações destrutivas exigem confirmação.

Implementar, quando aplicáveis:

- carregamento;
- vazio;
- sucesso;
- erro;
- offline;
- timeout;
- permissão negada;
- acesso não autorizado;
- sessão expirada;
- conflito;
- dados desatualizados.

## 9. Arquitetura Flutter

Preserve a arquitetura existente quando estiver adequada.

Em projeto novo ou mudança aprovada, separe:

- views;
- estado ou view models;
- domínio, quando necessário;
- repositórios;
- serviços;
- fontes locais;
- fontes remotas.

Não:

- colocar regra de negócio importante em widgets;
- chamar API diretamente da interface;
- alterar gerenciamento de estado sem justificativa;
- adicionar biblioteca por preferência;
- editar arquivo gerado manualmente;
- entregar mock como integração final sem informar;
- esconder overflow com redução excessiva da fonte.

## 10. Backend e dados

- Contratos devem ser definidos antes da integração dependente.
- Autenticação e autorização devem ser verificadas no servidor.
- Não confiar em perfil ou identificador enviado pelo cliente.
- Reservas devem tratar concorrência e duplicidade.
- Operações críticas devem tratar idempotência.
- Migrações devem ser versionadas e testadas.
- Alterações destrutivas exigem plano de recuperação.
- Dados pessoais devem ser minimizados.
- Logs não devem conter informações sensíveis.
- Sincronização offline deve possuir fonte de verdade e política de conflito.

## 11. Segurança

Não incluir no repositório:

- senhas;
- tokens;
- chaves privadas;
- credenciais;
- certificados privados;
- arquivos de assinatura;
- segredos de ambiente.

Não:

- autorizar apenas pela interface;
- registrar dados pessoais em logs;
- solicitar permissão sem necessidade;
- usar tráfego inseguro;
- publicar sem autorização;
- executar ação externa de produção sem autorização explícita.

## 12. Preservação do repositório

- Inspecionar antes de editar.
- Preservar alterações existentes do usuário.
- Não modificar arquivos não relacionados.
- Não realizar reformatação ampla sem necessidade.
- Não executar comando destrutivo.
- Não excluir dados ou arquivos sem autorização.
- Não fazer commit, push, merge ou publicação sem solicitação.
- Não substituir configuração existente sem avaliar impacto.

## 13. Verificação

Para arquivos Flutter alterados, execute quando disponível:

- formatação dos arquivos modificados;
- `flutter analyze`;
- `flutter test`;
- testes específicos da funcionalidade;
- build local quando necessário.

Não declare teste como aprovado sem executá-lo.

Quando um teste não puder ser executado, informe:

- qual teste;
- motivo;
- impacto;
- risco restante.

## 14. Matriz visual mínima

Nas telas afetadas, verificar quando aplicável:

- 320 × 568;
- 360 × 640;
- 390 × 844;
- 412 × 915;
- orientação horizontal;
- teclado aberto;
- fonte em 100%;
- fonte em 150%;
- fonte em 200%;
- textos longos;
- listas vazias;
- listas extensas;
- carregamento;
- erro;
- offline.

Não podem existir:

- RenderFlex overflow;
- sobreposição;
- conteúdo cortado;
- elementos fora da área segura;
- botões inacessíveis;
- conteúdo encoberto pelo teclado;
- texto importante ilegível.

## 15. Definição de pronto

Uma tarefa somente está pronta quando:

- critérios de aceite foram atendidos;
- regras institucionais necessárias foram confirmadas;
- código foi formatado;
- análise estática passou;
- testes relevantes passaram;
- estados de erro foram tratados;
- funcionamento offline foi considerado;
- não existe overflow conhecido;
- contratos foram atualizados;
- documentação afetada foi atualizada;
- QA aprovou;
- Segurança aprovou quando necessária;
- mocks indevidos foram removidos;
- limitações e pendências foram informadas.

Compilação isolada não significa conclusão.

## 16. Entrega

Sempre informar:

1. resultado alcançado;
2. escopo implementado;
3. arquivos criados e alterados;
4. contratos ou dados modificados;
5. decisões técnicas;
6. testes e comandos executados;
7. resultados;
8. dimensões ou ambientes verificados;
9. limitações;
10. riscos;
11. pendências;
12. parecer do QA;
13. parecer de Segurança, quando aplicável;
14. próximo passo somente quando necessário.