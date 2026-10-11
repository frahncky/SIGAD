import 'dart:ui' show Color;

import '../../../../app/theme/sigad_colors.dart';
import 'demanda_models.dart';

abstract final class DemandasService {
  static const List<String> statusDisponiveis = [
    'Novo',
    'Em andamento',
    'Aguardando',
    'Revisão',
    'Concluído',
  ];

  static const List<String> prioridades = ['Alta', 'Média', 'Baixa'];

  static const List<String> opcoesOrdenacao = [
    'Prazo mais próximo',
    'Prioridade',
    'Recém-criadas',
  ];

  static const List<String> proprietarios = [
    'Coordenação dos Cursos do DEE',
    'Secretaria Acadêmica',
    'Lab. de Máquinas Elétricas',
    'DTI do Campus',
    'Gestão de Pessoas',
    'Chefia do DEE',
    'Comissão de Estágio',
  ];

  static List<String> opcoesUnicas(
    Iterable<String> valores, {
    String? primeiro,
  }) {
    final vistos = <String>{};
    final resultado = <String>[];

    void adicionar(String valor) {
      final normalizado = valor.trim();
      if (normalizado.isEmpty) return;
      if (vistos.add(normalizado)) {
        resultado.add(normalizado);
      }
    }

    if (primeiro != null) {
      adicionar(primeiro);
    }
    for (final valor in valores) {
      adicionar(valor);
    }

    return resultado;
  }

  static List<Demanda> defaultDemandas() {
    return const [
      Demanda(
        id: '#DEM-001',
        titulo: 'Revisar inventário de instrumentos de medição',
        descricao:
            'Conferência dos instrumentos do Laboratório de Medidas Elétricas',
        prioridade: 'Alta',
        statusLabel: 'Em andamento',
        proprietario: 'Lab. de Máquinas Elétricas',
        prazo: '15/04/2026',
      ),
      Demanda(
        id: '#DEM-002',
        titulo: 'Mapear demandas semestre 2026.1',
        descricao: 'Levantamento de todas as solicitações do período',
        prioridade: 'Alta',
        statusLabel: 'Novo',
        proprietario: 'Coordenação dos Cursos do DEE',
        prazo: '20/04/2026',
      ),
      Demanda(
        id: '#DEM-003',
        titulo: 'Padronizar formulários de requisição',
        descricao: 'Unificar templates em uso no departamento',
        prioridade: 'Média',
        statusLabel: 'Aguardando',
        proprietario: 'Secretaria Acadêmica',
        prazo: '30/04/2026',
      ),
      Demanda(
        id: '#DEM-004',
        titulo: 'Auditoria de processos de estágio',
        descricao: 'Validação de fluxos e documentação',
        prioridade: 'Média',
        statusLabel: 'Revisão',
        proprietario: 'Comissão de Estágio',
        prazo: '25/04/2026',
      ),
      Demanda(
        id: '#DEM-005',
        titulo: 'Relatório de uso dos laboratórios',
        descricao: 'Análise de utilização de espaços e equipamentos',
        prioridade: 'Baixa',
        statusLabel: 'Concluído',
        proprietario: 'Chefia do DEE',
        prazo: '10/04/2026',
      ),
    ];
  }

  static List<Demanda> filtrarDemandas({
    required List<Demanda> demandas,
    required String busca,
    required String filtroStatus,
    required String filtroPrioridade,
  }) {
    return demandas
        .where((d) {
          final statusMatch =
              filtroStatus == 'Todas' || d.statusLabel == filtroStatus;
          final prioridadeMatch =
              filtroPrioridade == 'Todas' || d.prioridade == filtroPrioridade;
          final query = busca.trim().toLowerCase();
          final buscaMatch =
              query.isEmpty ||
              d.titulo.toLowerCase().contains(query) ||
              d.descricao.toLowerCase().contains(query) ||
              d.proprietario.toLowerCase().contains(query);
          return statusMatch && prioridadeMatch && buscaMatch;
        })
        .toList(growable: false);
  }

  static List<Demanda> ordenarDemandas(
    List<Demanda> demandas,
    String ordemSelecionada,
  ) {
    final list = [...demandas];
    switch (ordemSelecionada) {
      case 'Prioridade':
        list.sort((a, b) {
          final prioridade = pesoPrioridade(
            a.prioridade,
          ).compareTo(pesoPrioridade(b.prioridade));
          if (prioridade != 0) return prioridade;
          return parsePrazo(a.prazo).compareTo(parsePrazo(b.prazo));
        });
        break;
      case 'Recém-criadas':
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
      default:
        list.sort((a, b) => parsePrazo(a.prazo).compareTo(parsePrazo(b.prazo)));
    }
    return list;
  }

  static DateTime parsePrazo(String prazo) {
    final parts = prazo.split('/');
    if (parts.length != 3) return DateTime(2100);
    final dia = int.tryParse(parts[0]) ?? 1;
    final mes = int.tryParse(parts[1]) ?? 1;
    final ano = int.tryParse(parts[2]) ?? 2100;
    return DateTime(ano, mes, dia);
  }

  static int pesoPrioridade(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return 0;
      case 'Média':
        return 1;
      default:
        return 2;
    }
  }

  static Color toneStatus(String status) {
    switch (status) {
      case 'Novo':
        return SigadColors.brand;
      case 'Em andamento':
        return SigadColors.info;
      case 'Aguardando':
        return SigadColors.warning;
      case 'Revisão':
        return SigadColors.warning;
      case 'Concluído':
        return SigadColors.success;
      default:
        return SigadColors.muted;
    }
  }

  static Color tonePrioridade(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return SigadColors.risk;
      case 'Média':
        return SigadColors.warning;
      default:
        return SigadColors.success;
    }
  }

  static int countFiltrosAtivos({
    required String filtroStatus,
    required String filtroPrioridade,
    required String busca,
  }) {
    var ativos = 0;
    if (filtroStatus != 'Todas') ativos++;
    if (filtroPrioridade != 'Todas') ativos++;
    if (busca.trim().isNotEmpty) ativos++;
    return ativos;
  }

  static String gerarProximoIdDemanda(List<Demanda> demandas) {
    var maiorId = 0;
    for (final demanda in demandas) {
      final numero = int.tryParse(demanda.id.replaceAll(RegExp(r'[^0-9]'), ''));
      if (numero != null && numero > maiorId) {
        maiorId = numero;
      }
    }
    final proximoId = maiorId + 1;
    return '#DEM-${proximoId.toString().padLeft(3, '0')}';
  }

  static String dataAtual() {
    final agora = DateTime.now();
    final dia = agora.day.toString().padLeft(2, '0');
    final mes = agora.month.toString().padLeft(2, '0');
    final ano = agora.year.toString();
    return '$dia/$mes/$ano';
  }

  static String? validarDemanda({
    required String titulo,
    required String descricao,
  }) {
    if (titulo.trim().isEmpty) return 'Informe o título da demanda';
    if (descricao.trim().isEmpty) return 'Informe a descrição da demanda';
    return null;
  }
}
