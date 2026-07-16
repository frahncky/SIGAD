# Sistema de Roles e Permissões - SIGAD

## Visão Geral

O aplicativo SIGAD foi configurado com um sistema de múltiplos perfis de usuário para atender aos diferentes tipos de stakeholders dentro da instituição.

## Roles (Perfis) Disponíveis

### 1. **Professor (PR)**
  - ✅ Dashboard (Visão Geral)
  - ✅ Bate-papo local demonstrativo
  - ✅ Quadro de Tarefas
  - ✅ Laboratórios
  - ✅ Carga docente (consulta dos próprios dados)
  - ✅ Atividades
  - ✅ Calendário e Anotações
  - ❌ Demandas
  - ❌ Relatórios
  - ✅ Configurações

### 2. **Coordenador de Curso (CC)**
  - ✅ Dashboard (Visão Geral)
  - ✅ Bate-papo
  - ✅ Demandas
  - ✅ Quadro de Tarefas
  - ✅ Laboratórios
  - ✅ Carga docente
  - ✅ Atividades
  - ✅ Calendário e Anotações
  - ✅ Relatórios
  - ✅ Configurações

### 3. **Servidor Administrativo (SA)**
  - ✅ Dashboard (Visão Geral)
  - ✅ Bate-papo
  - ✅ Quadro de Tarefas
  - ✅ Atividades
  - ✅ Calendário e Anotações
  - ✅ Relatórios
  - ❌ Demandas
  - ❌ Laboratórios
  - ❌ Carga docente
  - ✅ Configurações

### 4. **Chefe do Departamento (CD)**
  - ✅ Dashboard (Visão Geral)
  - ✅ Bate-papo
  - ✅ Demandas
  - ✅ Quadro de Tarefas
  - ✅ Laboratórios
  - ✅ Carga docente (gestão e redistribuição)
  - ✅ Atividades
  - ✅ Calendário e Anotações
  - ✅ Relatórios
  - ✅ Configurações

## Funcionalidades Gerais (Disponíveis para Todos)

- **Dashboard**: Visão geral do sistema
- **Bate-papo**: Histórico local de demonstração; sem entrega ao destinatário
- **Quadro de Tarefas**: Visualização de tarefas em quadro de fluxo
- **Atividades**: Registro estruturado de entregas e eventos

## Sistema de Autenticação

### Fluxo de Login

1. Usuário acessa a aplicação
2. Se não autenticado, é redirecionado para a página de login (`/login`)
3. Em ambiente demonstrativo, insere dados locais e seleciona seu perfil
4. Em produção, o acesso permanece bloqueado até a integração institucional
5. Após login bem-sucedido:
   - Usuário é redirecionado ao Dashboard
   - Menu de navegação é filtrado conforme seu role
   - Perfil é exibido no drawer lateral

### Logout

- Botão "Sair" disponível no drawer do menu lateral
- Botão "Sair" no menu de perfil (ícone de conta)
- Ao fazer logout, usuário retorna à página de login

## Implementação Técnica

### Arquivos Criados/Modificados

#### Models
- `lib/core/models/user_role.dart` - Enum com os perfis disponíveis
- `lib/core/models/user.dart` - Modelo de usuário
- `lib/core/models/navigation_item.dart` - Modelo de item de navegação (atualizado)

#### Serviços
- `lib/core/services/user_context_provider.dart` - Provider para gerenciar contexto do usuário

#### Features
- `lib/features/login/presentation/pages/login_page.dart` - Página de login

#### Rotas
- `lib/app/routes/app_routes.dart` - Adicionado `/login`
- `lib/app/routes/app_router.dart` - Integração com login
- `lib/app/app.dart` - Integração com Provider

#### Navegação
- `lib/core/navigation/navigation_items.dart` - Filtro de itens por role
- `lib/features/home/presentation/pages/home_shell_page.dart` - Filtro dinâmico de menu

### Como Usar

#### Acessar User Context
```dart
final userContext = context.watch<UserContextProvider>();
final currentUser = userContext.currentUser;
final userRole = userContext.userRole;
```

#### Verificar Role
```dart
if (userContext.hasRole(UserRole.professor)) {
  // Fazer algo apenas para professores
}

if (userContext.hasAnyRole({UserRole.chefeDepartamento, UserRole.coordenador})) {
  // Fazer algo para chefes ou coordenadores
}
```

#### Fazer Login
```dart
final user = User(
  id: 'user_123',
  name: 'João Silva',
  email: 'joao@example.com',
  role: UserRole.professor,
  createdAt: DateTime.now(),
);
await context.read<UserContextProvider>().login(user);
```

#### Fazer Logout
```dart
await context.read<UserContextProvider>().logout();
Navigator.pushReplacementNamed(context, AppRoutes.login);
```

## Teste da Aplicação

### Contas de Demonstração

1. **Professor**: João Silva (joao.silva@univ.br)
2. **Coordenador**: Maria Santos (maria.santos@univ.br)
3. **Servidor Administrativo**: Carlos Admin (carlos.admin@univ.br)
4. **Chefe do Departamento**: Ana Chefe (ana.chefe@univ.br)

As contas e a seleção de perfil existem apenas quando o acesso demo está habilitado em `dev`, `test` ou `staging`.

## Próximos Passos

1. Integrar autenticação e diretório institucional do IFMA
2. Substituir persistência local por backend multiusuário
3. Integrar mensagens, notificações, convites, relatórios e backup
4. Enviar logs de auditoria para infraestrutura institucional
