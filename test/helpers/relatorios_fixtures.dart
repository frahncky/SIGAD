import 'package:sigad/core/config/app_runtime_config.dart';
import 'package:sigad/features/relatorios/data/relatorio_repository.dart';
import 'package:sigad/features/relatorios/domain/relatorio_models.dart';

/// Relatórios de teste (antes eram exibidos pela tela em produção como
/// exemplos). Não representam documentos institucionais.
const relatoriosFixture = [
  Relatorio(
    id: '#REL-001',
    titulo: 'Mapeamento de Demandas do Período',
    descricao:
        'Análise consolidada de todas as solicitações recebidas no semestre 2026.1',
    tipo: 'Análise Geral',
    data: '15/04/2026',
    autor: 'Coordenação Acadêmica',
    status: 'Publicado',
  ),
  Relatorio(
    id: '#REL-002',
    titulo: 'Distribuição de Carga Horária Docente',
    descricao: 'Relatório detalhado sobre equilíbrio de carga entre docentes',
    tipo: 'Recursos Humanos',
    data: '12/04/2026',
    autor: 'Departamento de RH',
    status: 'Publicado',
  ),
  Relatorio(
    id: '#REL-003',
    titulo: 'Indicadores de Desempenho - Q1 2026',
    descricao: 'Métricas de performance e KPIs do primeiro trimestre',
    tipo: 'Desempenho',
    data: '10/04/2026',
    autor: 'Gestão',
    status: 'Publicado',
  ),
  Relatorio(
    id: '#REL-004',
    titulo: 'Análise de Utilização de Laboratórios',
    descricao: 'Levantamento sobre uso de espaços e equipamentos',
    tipo: 'Infraestrutura',
    data: '18/04/2026',
    autor: 'Coordenação de Laboratórios',
    status: 'Em revisão',
  ),
  Relatorio(
    id: '#REL-005',
    titulo: 'Conformidade com Normas ISO',
    descricao:
        'Avaliação de conformidade dos processos com normas internacionais',
    tipo: 'Conformidade',
    data: '20/04/2026',
    autor: 'Auditoria Interna',
    status: 'Agendado',
  ),
];

/// Repositório controlável: devolve [dados] ou lança [erro].
class FakeRelatorioRepository extends RelatorioRepository {
  FakeRelatorioRepository({this.dados = const [], this.erro})
    : super(dataSourceMode: DataSourceMode.local);

  List<Relatorio> dados;
  Object? erro;
  int chamadas = 0;

  @override
  Future<List<Relatorio>> loadRelatorios() async {
    chamadas++;
    final falha = erro;
    if (falha != null) throw falha;
    return dados;
  }
}
