import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/welcome_hero.dart';
import '../../domain/mural_models.dart';
import '../mural_l10n.dart';
import '../mural_visual.dart';
import '../state/mural_controller.dart';

/// Gestão do mural do departamento: avisos do painel e frases motivacionais.
class MuralPage extends StatefulWidget {
  const MuralPage({super.key});

  @override
  State<MuralPage> createState() => _MuralPageState();
}

class _MuralPageState extends State<MuralPage> {
  @override
  void initState() {
    super.initState();
    context.read<MuralController>().carregar();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserContextProvider>().userRole;
    if (!AuthorizationPolicy.canManageMural(role)) {
      return const _AcessoNegado();
    }
    final l10n = context.l10n;
    final falhou = context.select<MuralController, bool>(
      (mural) => mural.falhouAoCarregar,
    );
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          if (falhou)
            MaterialBanner(
              content: Text(l10n.muralErroCarregar),
              actions: [const SizedBox.shrink()],
            ),
          TabBar(
            tabs: [
              Tab(text: l10n.avisos),
              Tab(text: l10n.muralFrases),
            ],
          ),
          const Expanded(
            child: TabBarView(children: [_AvisosTab(), _FrasesTab()]),
          ),
        ],
      ),
    );
  }
}

class _AcessoNegado extends StatelessWidget {
  const _AcessoNegado();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(context.l10n.muralAcessoNegado, textAlign: TextAlign.center),
    ),
  );
}

// ───────────────────────────── Avisos ─────────────────────────────

class _AvisosTab extends StatelessWidget {
  const _AvisosTab();

  @override
  Widget build(BuildContext context) {
    final mural = context.watch<MuralController>();
    final avisos = [...mural.avisos]
      ..sort((a, b) => b.criadoEm.compareTo(a.criadoEm));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context, null),
        icon: const SigadIcon(SigadIcons.adicionar),
        label: Text(context.l10n.muralNovoAviso),
      ),
      body: !mural.carregado
          ? const Center(child: CircularProgressIndicator())
          : avisos.isEmpty
          ? _Vazio(
              icone: SigadIcons.aviso,
              texto: context.l10n.muralNenhumAviso,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: avisos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _AvisoTile(
                aviso: avisos[index],
                agora: mural.agora(),
                onTap: () => _abrirFormulario(context, avisos[index]),
              ),
            ),
    );
  }

  void _abrirFormulario(BuildContext context, Aviso? aviso) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<MuralController>(),
          child: _AvisoForm(aviso: aviso),
        ),
      ),
    );
  }
}

class _AvisoTile extends StatelessWidget {
  const _AvisoTile({
    required this.aviso,
    required this.agora,
    required this.onTap,
  });

  final Aviso aviso;
  final DateTime agora;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hoje = DateUtils.dateOnly(agora);
    final inicio = aviso.inicio;
    final fim = aviso.fim;
    final status = !aviso.ativo
        ? l10n.muralDesativado
        : inicio != null && hoje.isBefore(DateUtils.dateOnly(inicio))
        ? l10n.muralAgendado
        : fim != null && hoje.isAfter(DateUtils.dateOnly(fim))
        ? l10n.muralEncerrado
        : l10n.muralNoAr;
    final publico = aviso.publico.isEmpty
        ? l10n.muralTodosPerfis
        : aviso.publico.map((perfil) => perfil.nomeEm(l10n)).join(', ');
    final fixado = aviso.fixado ? ' · ${l10n.muralFixado}' : '';

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: aviso.modelo.cor.withValues(alpha: 0.14),
          child: SigadIcon(aviso.modelo.icone, color: aviso.modelo.cor),
        ),
        title: Text(
          aviso.titulo,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${l10n.modeloAviso(aviso.modelo)} · $status$fixado\n$publico',
        ),
        isThreeLine: true,
        trailing: const SigadIcon(SigadIcons.editar),
      ),
    );
  }
}

class _AvisoForm extends StatefulWidget {
  const _AvisoForm({required this.aviso});

  final Aviso? aviso;

  @override
  State<_AvisoForm> createState() => _AvisoFormState();
}

class _AvisoFormState extends State<_AvisoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _conteudo;
  late ModeloAviso _modelo;
  late Set<UserRole> _publico;
  DateTime? _inicio;
  DateTime? _fim;
  late bool _fixado;
  late bool _ativo;
  bool _salvando = false;

  bool get _editando => widget.aviso != null;

  bool get _periodoInvalido =>
      _inicio != null &&
      _fim != null &&
      DateUtils.dateOnly(_fim!).isBefore(DateUtils.dateOnly(_inicio!));

  @override
  void initState() {
    super.initState();
    final aviso = widget.aviso;
    _titulo = TextEditingController(text: aviso?.titulo);
    _conteudo = TextEditingController(text: aviso?.conteudo);
    _modelo = aviso?.modelo ?? ModeloAviso.informativo;
    _publico = {...?aviso?.publico};
    _inicio = aviso?.inicio;
    _fim = aviso?.fim;
    _fixado = aviso?.fixado ?? false;
    _ativo = aviso?.ativo ?? true;
    _titulo.addListener(_atualizarPrevia);
    _conteudo.addListener(_atualizarPrevia);
  }

  void _atualizarPrevia() => setState(() {});

  @override
  void dispose() {
    _titulo.dispose();
    _conteudo.dispose();
    super.dispose();
  }

  Future<void> _escolherData({required bool inicio}) async {
    final mural = context.read<MuralController>();
    final hoje = mural.agora();
    final atual = inicio ? _inicio : _fim;
    final primeira = DateTime(hoje.year - 5);
    final ultima = DateTime(hoje.year + 5);
    var inicial = atual ?? _inicio ?? hoje;
    if (inicial.isBefore(primeira)) inicial = primeira;
    if (inicial.isAfter(ultima)) inicial = ultima;
    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: primeira,
      lastDate: ultima,
      helpText: inicio
          ? context.l10n.muralExibirAPartirDe
          : context.l10n.muralExibirAte,
    );
    if (escolhida == null) return;
    setState(() => inicio ? _inicio = escolhida : _fim = escolhida);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_periodoInvalido) {
      AppFeedbackService.warning(context, context.l10n.muralDataFinalInvalida);
      return;
    }
    final mural = context.read<MuralController>();
    final base =
        widget.aviso ??
        Aviso(
          id: mural.novoId(),
          modelo: _modelo,
          titulo: '',
          conteudo: '',
          criadoEm: mural.agora(),
        );
    final aviso = base.copyWith(
      modelo: _modelo,
      titulo: _titulo.text.trim(),
      conteudo: _conteudo.text.trim(),
      publico: _publico,
      inicio: () => _inicio,
      fim: () => _fim,
      fixado: _fixado,
      ativo: _ativo,
    );
    setState(() => _salvando = true);
    try {
      await mural.salvarAviso(aviso);
      if (!mounted) return;
      Navigator.pop(context);
      AppFeedbackService.success(context, context.l10n.muralAvisoPublicado);
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      AppFeedbackService.error(context, context.l10n.muralErroSalvarAviso);
    }
  }

  Future<void> _excluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.muralExcluirAvisoTitulo),
        content: Text(
          context.l10n.muralExcluirAvisoMensagem(widget.aviso!.titulo),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.excluir),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;
    final mural = context.read<MuralController>();
    setState(() => _salvando = true);
    try {
      await mural.excluirAviso(widget.aviso!.id);
      if (!mounted) return;
      Navigator.pop(context);
      AppFeedbackService.success(context, context.l10n.muralAvisoExcluido);
    } catch (_) {
      if (!mounted) return;
      setState(() => _salvando = false);
      AppFeedbackService.error(context, context.l10n.muralErroExcluirAviso);
    }
  }

  String _data(DateTime? data, String vazio) => data == null
      ? vazio
      : MaterialLocalizations.of(context).formatCompactDate(data);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? l10n.muralEditarAviso : l10n.muralNovoAviso),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(l10n.muralModelo, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final modelo in ModeloAviso.values)
                  ChoiceChip(
                    avatar: SigadIcon(modelo.icone, color: modelo.cor),
                    label: Text(l10n.modeloAviso(modelo)),
                    selected: _modelo == modelo,
                    onSelected: (_) => setState(() => _modelo = modelo),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titulo,
              maxLength: 80,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l10n.muralTitulo),
              validator: (valor) =>
                  (valor ?? '').trim().isEmpty ? l10n.muralInformeTitulo : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _conteudo,
              minLines: 8,
              maxLines: null,
              maxLength: 1000,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.muralConteudo,
                hintText: l10n.muralConteudoDica,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              validator: (valor) => (valor ?? '').trim().isEmpty
                  ? l10n.muralInformeConteudo
                  : null,
            ),
            const SizedBox(height: 16),
            Text(l10n.muralQuemVe, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(l10n.muralTodos),
                  selected: _publico.isEmpty,
                  onSelected: (_) => setState(() => _publico = {}),
                ),
                for (final perfil in UserRole.values)
                  FilterChip(
                    label: Text(perfil.nomeEm(l10n)),
                    selected: _publico.contains(perfil),
                    onSelected: (selecionado) => setState(() {
                      selecionado
                          ? _publico.add(perfil)
                          : _publico.remove(perfil);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.muralPeriodoExibicao, style: theme.textTheme.titleSmall),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const SigadIcon(SigadIcons.calendario),
              title: Text(l10n.muralAPartirDe),
              subtitle: Text(_data(_inicio, l10n.muralImediatamente)),
              trailing: _inicio == null
                  ? null
                  : IconButton(
                      tooltip: l10n.muralLimparDataInicial,
                      icon: const SigadIcon(SigadIcons.fechar),
                      onPressed: () => setState(() => _inicio = null),
                    ),
              onTap: () => _escolherData(inicio: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const SigadIcon(SigadIcons.eventoOcupado),
              title: Text(l10n.muralAte),
              subtitle: Text(_data(_fim, l10n.muralSemDataSair)),
              trailing: _fim == null
                  ? null
                  : IconButton(
                      tooltip: l10n.muralLimparDataFinal,
                      icon: const SigadIcon(SigadIcons.fechar),
                      onPressed: () => setState(() => _fim = null),
                    ),
              onTap: () => _escolherData(inicio: false),
            ),
            if (_periodoInvalido)
              Text(
                l10n.muralDataFinalInvalida,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.muralFixarTopo),
              subtitle: Text(l10n.muralFixarTopoSub),
              value: _fixado,
              onChanged: (valor) => setState(() => _fixado = valor),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.muralAtivo),
              subtitle: Text(l10n.muralAtivoSub),
              value: _ativo,
              onChanged: (valor) => setState(() => _ativo = valor),
            ),
            const SizedBox(height: 24),
            Text(l10n.muralPreviaPainel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(l10n.muralPreviaAvisoSub, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            WelcomeHero(
              avisos: [
                WelcomeHeroItem(
                  icon: _modelo.icone,
                  title: _titulo.text.trim().isEmpty
                      ? l10n.muralPreviaTitulo
                      : _titulo.text.trim(),
                  subtitle: _conteudo.text.trim().isEmpty
                      ? l10n.muralPreviaConteudo
                      : _conteudo.text.trim(),
                  color: _modelo.cor,
                ),
              ],
              paginaInicial: 1,
              rotacaoAutomatica: false,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: const SigadIcon(SigadIcons.enviar),
              label: Text(l10n.muralPublicarAviso),
            ),
            if (_editando) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _salvando ? null : _excluir,
                icon: SigadIcon(
                  SigadIcons.excluir,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  l10n.muralExcluirAviso,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── Frases ─────────────────────────────

class _FrasesTab extends StatelessWidget {
  const _FrasesTab();

  @override
  Widget build(BuildContext context) {
    final mural = context.watch<MuralController>();
    final theme = Theme.of(context);
    final atual = mural.fraseAtual;
    final l10n = context.l10n;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editarFrase(context, null),
        icon: const SigadIcon(SigadIcons.adicionar),
        label: Text(l10n.muralNovaFrase),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text(l10n.muralTrocarFrase, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<PeriodicidadeFrase>(
            key: ValueKey(mural.periodicidade),
            initialValue: mural.periodicidade,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: SigadIcon(SigadIcons.atualizar),
            ),
            items: [
              for (final item in PeriodicidadeFrase.values)
                DropdownMenuItem(
                  value: item,
                  child: Text(l10n.periodicidadeFrase(item)),
                ),
            ],
            onChanged: (valor) async {
              if (valor == null) return;
              try {
                await mural.definirPeriodicidade(valor);
              } catch (_) {
                if (context.mounted) {
                  AppFeedbackService.error(context, l10n.muralErroFrequencia);
                }
              }
            },
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.muralFraseEmExibicao,
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    atual?.texto ?? l10n.muralNenhumaFrase,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.muralFrasesLista(mural.frases.length),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final frase in mural.frases)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => _editarFrase(context, frase),
                title: Text(frase.texto),
                leading: Semantics(
                  label: l10n.muralFraseAtivaRodizio,
                  child: Switch(
                    value: frase.ativa,
                    onChanged: (valor) =>
                        _salvar(context, frase.copyWith(ativa: valor)),
                  ),
                ),
                trailing: IconButton(
                  tooltip: l10n.muralExcluirFrase,
                  icon: const SigadIcon(SigadIcons.excluir),
                  onPressed: () => _excluir(context, frase),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _salvar(BuildContext context, FraseMotivacional frase) async {
    try {
      await context.read<MuralController>().salvarFrase(frase);
    } catch (_) {
      if (context.mounted) {
        AppFeedbackService.error(context, context.l10n.muralErroSalvarFrase);
      }
    }
  }

  Future<void> _excluir(BuildContext context, FraseMotivacional frase) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.muralExcluirFraseTitulo),
        content: Text('"${frase.texto}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.excluir),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;
    try {
      await context.read<MuralController>().excluirFrase(frase.id);
    } catch (_) {
      if (context.mounted) {
        AppFeedbackService.error(context, context.l10n.muralErroExcluirFrase);
      }
    }
  }

  Future<void> _editarFrase(
    BuildContext context,
    FraseMotivacional? frase,
  ) async {
    final mural = context.read<MuralController>();
    final texto = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FraseForm(textoInicial: frase?.texto ?? ''),
      ),
    );
    if (texto == null || !context.mounted) return;
    await _salvar(
      context,
      frase?.copyWith(texto: texto) ??
          FraseMotivacional(id: mural.novoId(), texto: texto),
    );
  }
}

/// Tela de edição de frase, com pré-visualização do card de boas-vindas.
class _FraseForm extends StatefulWidget {
  const _FraseForm({required this.textoInicial});

  final String textoInicial;

  @override
  State<_FraseForm> createState() => _FraseFormState();
}

class _FraseFormState extends State<_FraseForm> {
  late final _controller = TextEditingController(text: widget.textoInicial)
    ..addListener(() => setState(() {}));
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _publicar() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texto = _controller.text.trim();
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.textoInicial.isEmpty
              ? l10n.muralNovaFrase
              : l10n.muralEditarFrase,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              minLines: 5,
              maxLines: null,
              maxLength: 160,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.muralFrase,
                hintText: l10n.muralFraseDica,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
              validator: (valor) =>
                  (valor ?? '').trim().isEmpty ? l10n.muralEscrevaFrase : null,
            ),
            const SizedBox(height: 24),
            Text(l10n.muralPreviaPainel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(l10n.muralPreviaFraseSub, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            WelcomeHero(
              frase: texto.isEmpty ? l10n.muralPreviaFrase : texto,
              rotacaoAutomatica: false,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _publicar,
              icon: const SigadIcon(SigadIcons.enviar),
              label: Text(l10n.muralSalvarFrase),
            ),
          ],
        ),
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SigadIcon(
            icone,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(texto, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
