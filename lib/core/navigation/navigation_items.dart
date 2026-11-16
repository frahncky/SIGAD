import '../../app/routes/app_routes.dart';
import '../../app/theme/sigad_icons.dart';
import '../models/navigation_item.dart';
import '../models/user_role.dart';

const List<NavigationItem> kNavigationItems = [
  NavigationItem(
    route: AppRoutes.dashboard,
    label: 'Visão geral',
    subtitle: 'Indicadores, prioridades e atalhos',
    icon: SigadIcons.painel,
  ),
  // Bate-papo fica fora da navegação até existir servidor: hoje as mensagens
  // ficam só no aparelho e não chegam a ninguém. A rota e a tela continuam no
  // código para voltar quando houver entrega real.
  NavigationItem(
    route: AppRoutes.demandas,
    label: 'Demandas',
    subtitle: 'Solicitações, prazos e responsáveis',
    icon: SigadIcons.demanda,
    availableFor: {UserRole.coordenador, UserRole.chefeDepartamento},
  ),
  NavigationItem(
    route: AppRoutes.professores,
    label: 'Professores',
    subtitle: 'Cadastro, situação e carga atribuída',
    icon: SigadIcons.professor,
    availableFor: {
      UserRole.professor,
      UserRole.coordenador,
      UserRole.chefeDepartamento,
    },
  ),
  NavigationItem(
    route: AppRoutes.kanban,
    label: 'Tarefas',
    subtitle: 'Quadro de acompanhamento das atividades',
    icon: SigadIcons.kanban,
  ),
  NavigationItem(
    route: AppRoutes.aulasPraticas,
    label: 'Laboratórios',
    subtitle: 'Ocupação, reservas e conflitos',
    icon: SigadIcons.laboratorio,
    availableFor: {
      UserRole.professor,
      UserRole.coordenador,
      UserRole.chefeDepartamento,
    },
  ),
  NavigationItem(
    route: AppRoutes.cargaDocente,
    label: 'Carga docente',
    subtitle: 'Distribuição de aulas e atividades',
    icon: SigadIcons.relogio,
    availableFor: {
      UserRole.professor,
      UserRole.coordenador,
      UserRole.chefeDepartamento,
    },
  ),
  NavigationItem(
    route: AppRoutes.atividades,
    label: 'Atividades',
    subtitle: 'Ensino, pesquisa, extensão e gestão',
    icon: SigadIcons.checklist,
  ),
  NavigationItem(
    route: AppRoutes.relatorios,
    label: 'Relatórios',
    subtitle: 'Indicadores e exportações gerenciais',
    icon: SigadIcons.analise,
    availableFor: {
      UserRole.coordenador,
      UserRole.servidorAdministrativo,
      UserRole.chefeDepartamento,
    },
  ),
  NavigationItem(
    route: AppRoutes.configuracoes,
    label: 'Configurações',
    subtitle: 'Conta, preferências e permissões',
    icon: SigadIcons.configuracoes,
    availableFor: {
      UserRole.professor,
      UserRole.coordenador,
      UserRole.servidorAdministrativo,
      UserRole.chefeDepartamento,
    },
  ),
];
