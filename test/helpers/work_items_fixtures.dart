import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sigad/app/theme/app_theme.dart';
import 'package:sigad/features/atividades/data/atividade_repository.dart';
import 'package:sigad/features/atividades/domain/atividade_models.dart';
import 'package:sigad/features/kanban/data/kanban_repository.dart';
import 'package:sigad/features/kanban/domain/kanban_models.dart';
import 'package:sigad/l10n/l10n.dart';

/// Tarefas de teste (antes eram semeadas pela tela em produção).
const kanbanFixture = [
  KanbanCardModel(
    id: 1,
    titulo: 'Revisão de inventário',
    coluna: 'Backlog',
    prioridade: 'Alta',
  ),
  KanbanCardModel(
    id: 2,
    titulo: 'Mapear demandas',
    coluna: 'Em Progresso',
    prioridade: 'Alta',
  ),
  KanbanCardModel(
    id: 3,
    titulo: 'Padronizar formulários',
    coluna: 'Em Revisão',
    prioridade: 'Média',
  ),
  KanbanCardModel(
    id: 4,
    titulo: 'Auditoria de estágio',
    coluna: 'Em Revisão',
    prioridade: 'Média',
  ),
  KanbanCardModel(
    id: 5,
    titulo: 'Relatório de labs',
    coluna: 'Concluído',
    prioridade: 'Baixa',
  ),
  KanbanCardModel(
    id: 6,
    titulo: 'Planejar semestre',
    coluna: 'Backlog',
    prioridade: 'Alta',
  ),
  KanbanCardModel(
    id: 7,
    titulo: 'Revisar documentação',
    coluna: 'Em Progresso',
    prioridade: 'Média',
  ),
];

/// Atividades de teste (antes eram semeadas pela tela em produção).
const atividadesFixture = [
  Atividade(
    id: '#ATV-001',
    titulo: 'Entrega de levantamento de demandas',
    descricao: 'Documento consolidado com todas as solicitações do período',
    data: '15/04/2026 - 10:30',
    responsavel: 'Coordenação',
    status: 'Concluída',
  ),
  Atividade(
    id: '#ATV-002',
    titulo: 'Reunião de validação de requisitos',
    descricao: 'Apresentação dos requisitos para as áreas envolvidas',
    data: '18/04/2026 - 14:00',
    responsavel: 'Gestão',
    status: 'Concluída',
  ),
  Atividade(
    id: '#ATV-003',
    titulo: 'Implementação de sistema de priorização',
    descricao: 'Desenvolvimento da matriz de priorização',
    data: '22/04/2026 - 09:00',
    responsavel: 'TI',
    status: 'Em progresso',
  ),
  Atividade(
    id: '#ATV-004',
    titulo: 'Treinamento de usuários',
    descricao: 'Capacitação de usuários no novo sistema',
    data: '28/04/2026 - 08:00',
    responsavel: 'RH',
    status: 'Agendada',
  ),
  Atividade(
    id: '#ATV-005',
    titulo: 'Auditoria de conformidade',
    descricao: 'Verificação de conformidade',
    data: '05/05/2026 - 13:00',
    responsavel: 'Auditoria',
    status: 'Agendada',
  ),
  Atividade(
    id: '#ATV-006',
    titulo: 'Publicação de resultados',
    descricao: 'Divulgação dos resultados para a comunidade acadêmica',
    data: '10/05/2026',
    responsavel: 'Comunicação',
    status: 'Pendente',
  ),
];

/// Repositório em memória do quadro, com gravação controlável.
class FakeKanbanRepository extends KanbanRepository {
  FakeKanbanRepository([List<KanbanCardModel> cards = kanbanFixture])
    : cards = List.of(cards),
      super(storageKey: 'fake_kanban');

  List<KanbanCardModel> cards;
  int saves = 0;
  Object? falha;
  Completer<void>? pendente;

  @override
  Future<List<KanbanCardModel>> loadCards() async => List.of(cards);

  @override
  Future<void> saveCards(List<KanbanCardModel> novos) async {
    saves++;
    if (pendente != null) await pendente!.future;
    if (falha != null) throw falha!;
    cards = List.of(novos);
  }
}

/// Repositório em memória das atividades, com gravação controlável.
class FakeAtividadeRepository extends AtividadeRepository {
  FakeAtividadeRepository([List<Atividade> atividades = atividadesFixture])
    : atividades = List.of(atividades),
      super(storageKey: 'fake_atividades');

  List<Atividade> atividades;
  int saves = 0;
  Object? falha;
  Completer<void>? pendente;

  @override
  Future<List<Atividade>> loadAtividades() async => List.of(atividades);

  @override
  Future<void> saveAtividades(List<Atividade> novas) async {
    saves++;
    if (pendente != null) await pendente!.future;
    if (falha != null) throw falha!;
    atividades = List.of(novas);
  }
}

/// Tamanhos da matriz visual mínima do projeto.
const matrizTamanhos = [
  Size(320, 568),
  Size(360, 640),
  Size(390, 844),
  Size(412, 915),
  Size(568, 320),
];

const matrizEscalas = [1.0, 1.5, 2.0];

void configurarTela(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
}

/// App mínimo em português (padrão) com escala de fonte configurável.
Widget appDeTeste(
  Widget home, {
  double textScale = 1,
  Locale locale = const Locale('pt'),
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? AppTheme.light(),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  );
}

/// Falha com contexto se houve exceção de layout (overflow etc.).
void semExcecao(WidgetTester tester, String contexto) {
  final erro = tester.takeException();
  expect(erro, isNull, reason: '$contexto: $erro');
}
