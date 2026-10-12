import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../domain/docente_models.dart';
import '../../data/docente_repository.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_tone_palette.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/icon_avatar.dart';
import 'package:provider/provider.dart';

class ProfessoresPage extends StatefulWidget {
  const ProfessoresPage({super.key});

  @override
  State<ProfessoresPage> createState() => _ProfessoresPageState();
}

class _ProfessoresPageState extends State<ProfessoresPage> {
  bool _ordemCrescente = true;
  final TextEditingController _buscaController = TextEditingController();
  String _busca = '';
  final DocenteRepository _docenteRepository = DocenteRepository();
  List<Docente> _docentes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final carregados = await _docenteRepository.loadDocentes(
      generateFallbackId: () =>
          DateTime.now().millisecondsSinceEpoch.toString(),
    );
    setState(() {
      _docentes = carregados;
    });
  }

  void _abrirAgendaDocente(Docente docente) {
    Navigator.of(context).pushNamed('/carga-docente', arguments: docente);
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    final podeGerenciar =
        role == UserRole.coordenador || role == UserRole.chefeDepartamento;
    final docentesFiltrados = _busca.isEmpty
        ? List<Docente>.from(_docentes)
        : _docentes.where((d) {
            final buscaLower = _busca.toLowerCase();
            return d.nome.toLowerCase().contains(buscaLower) ||
                (d.userEmail ?? '').toLowerCase().contains(buscaLower) ||
                d.departamento.toLowerCase().contains(buscaLower);
          }).toList();
    docentesFiltrados.sort(
      (a, b) => _ordemCrescente
          ? a.nome.toLowerCase().compareTo(b.nome.toLowerCase())
          : b.nome.toLowerCase().compareTo(a.nome.toLowerCase()),
    );
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navProfessores)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscaController,
                    onChanged: (value) => setState(() => _busca = value),
                    decoration: InputDecoration(
                      hintText: context.l10n.cdBuscarDocente,
                      prefixIcon: SigadIcon(
                        SigadIcons.buscar,
                        color: SigadColors.brand,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: _ordemCrescente
                      ? context.l10n.cdOrdemCrescente
                      : context.l10n.cdOrdemDecrescente,
                  icon: SigadIcon(
                    _ordemCrescente
                        ? SigadIcons.setaBaixo
                        : SigadIcons.setaCima,
                    color: SigadColors.brand,
                  ),
                  onPressed: () {
                    setState(() {
                      _ordemCrescente = !_ordemCrescente;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: docentesFiltrados.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.cdNenhumDocente,
                      style: textTheme.bodyLarge,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: docentesFiltrados.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final docente = docentesFiltrados[index];
                      return Card(
                        child: ListTile(
                          leading: SigadIconAvatar(
                            icon: SigadIcons.professor,
                            tone: sigadToneForIndex(index),
                          ),
                          title: Text(docente.nome),
                          subtitle: Text(docente.departamento),
                          trailing: podeGerenciar
                              ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    // Adicionar ações de editar/excluir se necessário
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'editar',
                                      child: Text(context.l10n.demEditarAcao),
                                    ),
                                    PopupMenuItem(
                                      value: 'excluir',
                                      child: Text(context.l10n.excluir),
                                    ),
                                  ],
                                )
                              : null,
                          onTap: () => _abrirAgendaDocente(docente),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: podeGerenciar
          ? FloatingActionButton(
              onPressed: () {
                // Adicionar novo docente
              },
              tooltip: context.l10n.cdAdicionarDocente,
              child: const SigadIcon(SigadIcons.adicionar),
            )
          : null,
    );
  }
}
