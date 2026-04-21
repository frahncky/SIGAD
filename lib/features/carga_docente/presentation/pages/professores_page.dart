import 'package:flutter/material.dart';
import '../../domain/docente_models.dart';
import '../../data/docente_repository.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/services/user_context_provider.dart';
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
      generateFallbackId: () => DateTime.now().millisecondsSinceEpoch.toString(),
    );
    setState(() {
      _docentes = carregados;
    });
  }

  void _abrirAgendaDocente(Docente docente) {
    Navigator.of(context).pushNamed(
      '/carga-docente',
      arguments: docente,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    final podeGerenciar = role == UserRole.coordenador || role == UserRole.chefeDepartamento;
    List<Docente> docentesFiltrados = _busca.isEmpty
      ? List<Docente>.from(_docentes)
      : _docentes.where((d) {
        final buscaLower = _busca.toLowerCase();
        return d.nome.toLowerCase().contains(buscaLower) ||
          (d.userEmail ?? '').toLowerCase().contains(buscaLower) ||
          d.departamento.toLowerCase().contains(buscaLower);
        }).toList();
    docentesFiltrados.sort((a, b) => _ordemCrescente
      ? a.nome.toLowerCase().compareTo(b.nome.toLowerCase())
      : b.nome.toLowerCase().compareTo(a.nome.toLowerCase()));
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Professores')),
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
                    decoration: const InputDecoration(
                      hintText: 'Buscar docente por nome, e-mail ou departamento',
                      prefixIcon: Icon(Icons.search_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: _ordemCrescente ? 'Ordem crescente' : 'Ordem decrescente',
                  icon: Icon(_ordemCrescente ? Icons.arrow_downward : Icons.arrow_upward),
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
                    child: Text('Nenhum docente encontrado', style: textTheme.bodyLarge),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: docentesFiltrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final docente = docentesFiltrados[index];
                      return Card(
                        child: ListTile(
                          title: Text(docente.nome),
                          subtitle: Text(docente.departamento),
                          trailing: podeGerenciar
                              ? PopupMenuButton<String>(
                                  onSelected: (value) {
                                    // Adicionar ações de editar/excluir se necessário
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'editar',
                                      child: Text('Editar'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'excluir',
                                      child: Text('Excluir'),
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
              tooltip: 'Adicionar docente',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
