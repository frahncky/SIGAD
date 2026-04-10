import 'package:flutter/material.dart';
import '../../../../app/theme/sigad_colors.dart';

class CargaDocentePage extends StatefulWidget {
  const CargaDocentePage({super.key});

  @override
  State<CargaDocentePage> createState() => _CargaDocentePageState();
}

class _CargaDocentePageState extends State<CargaDocentePage> {
  String _filtro = 'Todos';

  final List<_Docente> _docentes = [
    _Docente(
      id: '#DOC-001',
      nome: 'Profa. Dra. Maria Silva',
      departamento: 'Engenharia de Software',
      cargaHoraria: 20,
      cargaMaxima: 20,
      disciplinas: ['Programação I', 'Programação II', 'Engenharia de Software'],
      disponibilidade: 'Indisponível',
      toneDisponibilidade: SigadColors.risk,
    ),
    _Docente(
      id: '#DOC-002',
      nome: 'Prof. Dr. João Santos',
      departamento: 'Sistemas de Informação',
      cargaHoraria: 16,
      cargaMaxima: 20,
      disciplinas: ['Banco de Dados', 'Web Design'],
      disponibilidade: 'Disponível',
      toneDisponibilidade: SigadColors.success,
    ),
    _Docente(
      id: '#DOC-003',
      nome: 'Profa. Ana Costa',
      departamento: 'Engenharia de Software',
      cargaHoraria: 12,
      cargaMaxima: 20,
      disciplinas: ['Computação Gráfica'],
      disponibilidade: 'Disponível',
      toneDisponibilidade: SigadColors.success,
    ),
    _Docente(
      id: '#DOC-004',
      nome: 'Prof. Carlos Oliveira',
      departamento: 'Redes e Telecomunicações',
      cargaHoraria: 18,
      cargaMaxima: 20,
      disciplinas: ['Redes I', 'Redes II', 'Segurança de Redes'],
      disponibilidade: 'Parcialmente',
      toneDisponibilidade: SigadColors.warning,
    ),
    _Docente(
      id: '#DOC-005',
      nome: 'Profa. Beatriz Mendes',
      departamento: 'Engenharia de Software',
      cargaHoraria: 14,
      cargaMaxima: 20,
      disciplinas: ['Qualidade de Software'],
      disponibilidade: 'Disponível',
      toneDisponibilidade: SigadColors.success,
    ),
  ];

  List<_Docente> get _docentesFiltrados {
    if (_filtro == 'Todos') return _docentes;
    return _docentes.where((d) => d.disponibilidade == _filtro).toList();
  }

  void _showAdicionarDocente(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nomeController = TextEditingController();
    final departamentoController = TextEditingController();
    final cargaMaximaController = TextEditingController();
    String disponibilidadeSelecionada = 'Disponível';
    final List<String> disciplinas = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Novo Docente', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Digite o nome do docente',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: departamentoController,
                decoration: const InputDecoration(
                  labelText: 'Departamento',
                  hintText: 'Digite o departamento',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cargaMaximaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Carga Horária Máxima (horas)',
                  hintText: 'Ex: 20',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: disponibilidadeSelecionada,
                decoration: const InputDecoration(labelText: 'Disponibilidade'),
                items: ['Disponível', 'Parcialmente', 'Indisponível']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => setState(() => disponibilidadeSelecionada = value!),
              ),
              const SizedBox(height: 16),
              Text(
                'Disciplinas',
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...disciplinas.map((d) => Chip(
                        label: Text(d),
                        onDeleted: () => setState(() => disciplinas.remove(d)),
                      )),
                  ActionChip(
                    label: const Text('Adicionar'),
                    onPressed: () => _showAdicionarDisciplina(context, disciplinas, setState),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Aqui seria implementada a lógica para salvar o docente
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Docente adicionado com sucesso!')),
                        );
                      },
                      child: const Text('Adicionar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdicionarDisciplina(BuildContext context, List<String> disciplinas, StateSetter setState) {
    final disciplinaController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Disciplina'),
        content: TextField(
          controller: disciplinaController,
          decoration: const InputDecoration(
            labelText: 'Nome da Disciplina',
            hintText: 'Ex: Programação I',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (disciplinaController.text.isNotEmpty) {
                setState(() => disciplinas.add(disciplinaController.text));
              }
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carga Docente'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'Todos',
                  'Disponível',
                  'Parcialmente',
                  'Indisponível'
                ]
                    .map((status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status),
                            selected: _filtro == status,
                            onSelected: (selected) {
                              setState(() => _filtro = selected ? status : 'Todos');
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: _docentesFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 64,
                          color: SigadColors.muted.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum docente encontrado',
                          style: textTheme.bodyLarge?.copyWith(color: SigadColors.muted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _docentesFiltrados.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => _DocenteCard(
                      docente: _docentesFiltrados[index],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdicionarDocente(context),
        backgroundColor: SigadColors.brand,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DocenteCard extends StatelessWidget {
  const _DocenteCard({required this.docente});

  final _Docente docente;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percentualCarga = (docente.cargaHoraria / docente.cargaMaxima * 100).toInt();

    return GestureDetector(
      onTap: () => _showDetalhes(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SigadColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SigadColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SigadColors.brand,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      docente.nome.split(' ').map((e) => e[0]).join('').substring(0, 2),
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docente.nome,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        docente.departamento,
                        style: textTheme.bodySmall?.copyWith(
                          color: SigadColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: docente.toneDisponibilidade.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    docente.disponibilidade,
                    style: textTheme.labelSmall?.copyWith(
                      color: docente.toneDisponibilidade,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _onMenuItemSelected(context, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'excluir',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: docente.cargaHoraria / docente.cargaMaxima,
                minHeight: 8,
                backgroundColor: SigadColors.muted.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentualCarga >= 100 ? SigadColors.risk : SigadColors.success,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${docente.cargaHoraria}h / ${docente.cargaMaxima}h',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$percentualCarga%',
                  style: textTheme.labelSmall?.copyWith(
                    color: SigadColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: docente.disciplinas
                  .map((d) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: SigadColors.brand.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          d,
                          style: textTheme.labelSmall?.copyWith(
                            color: SigadColors.brand,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _onMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'editar':
        _showEditarDocente(context);
        break;
      case 'excluir':
        _showConfirmarExclusao(context);
        break;
    }
  }

  void _showEditarDocente(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final nomeController = TextEditingController(text: docente.nome);
    final departamentoController = TextEditingController(text: docente.departamento);
    final cargaMaximaController = TextEditingController(text: docente.cargaMaxima.toString());
    String disponibilidadeSelecionada = docente.disponibilidade;
    final List<String> disciplinas = List.from(docente.disciplinas);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Editar Docente', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Digite o nome do docente',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: departamentoController,
                decoration: const InputDecoration(
                  labelText: 'Departamento',
                  hintText: 'Digite o departamento',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cargaMaximaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Carga Horária Máxima (horas)',
                  hintText: 'Ex: 20',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: disponibilidadeSelecionada,
                decoration: const InputDecoration(labelText: 'Disponibilidade'),
                items: ['Disponível', 'Parcialmente', 'Indisponível']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => setState(() => disponibilidadeSelecionada = value!),
              ),
              const SizedBox(height: 16),
              Text(
                'Disciplinas',
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...disciplinas.map((d) => Chip(
                        label: Text(d),
                        onDeleted: () => setState(() => disciplinas.remove(d)),
                      )),
                  ActionChip(
                    label: const Text('Adicionar'),
                    onPressed: () => _showAdicionarDisciplina(context, disciplinas, setState),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Aqui seria implementada a lógica para atualizar o docente
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Docente atualizado com sucesso!')),
                        );
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este docente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Aqui seria implementada a lógica para excluir o docente
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Docente excluído com sucesso!')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAdicionarDisciplina(BuildContext context, List<String> disciplinas, StateSetter setState) {
    final disciplinaController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Disciplina'),
        content: TextField(
          controller: disciplinaController,
          decoration: const InputDecoration(
            labelText: 'Nome da Disciplina',
            hintText: 'Ex: Programação I',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (disciplinaController.text.isNotEmpty) {
                setState(() => disciplinas.add(disciplinaController.text));
              }
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showDetalhes(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percentualCarga = (docente.cargaHoraria / docente.cargaMaxima * 100).toInt();

    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(docente.id, style: textTheme.labelSmall?.copyWith(color: SigadColors.muted)),
                      const SizedBox(height: 8),
                      Text(docente.nome, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailSection(label: 'Departamento', value: docente.departamento),
              _DetailSection(label: 'Carga Horária', value: '${docente.cargaHoraria}h / ${docente.cargaMaxima}h ($percentualCarga%)'),
              _DetailSection(label: 'Disponibilidade', value: docente.disponibilidade),
              const SizedBox(height: 16),
              Text(
                'Disciplinas',
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: docente.disciplinas
                    .map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: SigadColors.success),
                              const SizedBox(width: 8),
                              Text(d, style: textTheme.bodySmall),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: SigadColors.muted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Docente {
  const _Docente({
    required this.id,
    required this.nome,
    required this.departamento,
    required this.cargaHoraria,
    required this.cargaMaxima,
    required this.disciplinas,
    required this.disponibilidade,
    required this.toneDisponibilidade,
  });

  final String id;
  final String nome;
  final String departamento;
  final int cargaHoraria;
  final int cargaMaxima;
  final List<String> disciplinas;
  final String disponibilidade;
  final Color toneDisponibilidade;
}
