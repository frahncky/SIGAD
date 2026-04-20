# Sprint 5 - Checklist de Execucao

## Objetivo
Elevar a qualidade da experiencia do usuario com tema escuro funcional, notificacoes dinamicas por perfil de usuario e acessibilidade basica.

## Pilar 1 - Tema Escuro Funcional
- [x] Implementar AppTheme.dark() com paleta adaptada
- [x] Criar ThemeProvider (ChangeNotifier) com ThemeMode
- [x] Integrar ThemeProvider no SigadApp (themeMode reativo via Consumer)
- [x] Conectar toggle de modo noturno em Configuracoes ao ThemeProvider
- [x] Persistir preferencia de tema entre sessoes (via ConfiguracoesRepository)
- [x] Inicializar ThemeProvider com preferencia salva na splash (main.dart)

## Pilar 2 - Notificacoes Dinamicas
- [x] Criar NotificacaoModel com titulo, subtitulo e icone
- [x] Criar NotificacoesService com notificacoes especificas por UserRole
- [x] Badge reativo no icone de sino do AppBar mobile
- [x] Remover ListTiles hardcoded do painel de notificacoes
- [x] Painel de notificacoes exibe itens dinamicos por perfil ativo

## Pilar 3 - Acessibilidade
- [x] Garantir Tooltip em todos os IconButtons de acao critica

## Pilar 4 - Qualidade
- [x] Testes unitarios para ThemeProvider
- [x] Testes unitarios para NotificacoesService
- [x] Todos os testes passando sem regressoes
- [x] flutter analyze sem issues nos arquivos alterados

## Definicao de Pronto (DoD)
- [x] Toggle de modo noturno em Configuracoes muda o app imediatamente
- [x] Painel de notificacoes exibe itens relevantes ao perfil logado
- [x] Badge de sino exibe contagem real de notificacoes do perfil
- [x] Preferencia de tema sobrevive a reinicializacao do app
- [x] flutter test sem falhas

## Sequencia de Implementacao
1. ThemeProvider + AppTheme.dark()
2. Integracao no SigadApp e main.dart
3. Conexao com ConfiguracoesPage
4. NotificacoesService + badge
5. Acessibilidade
6. Testes e validacao
