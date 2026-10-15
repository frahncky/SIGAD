import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../app/theme/sigad_tone_palette.dart';
import '../../../../core/navigation/navigation_items.dart';
import '../../../../core/services/notificacoes_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../mural/presentation/mural_visual.dart';
import '../../../mural/presentation/state/mural_controller.dart';
import '../../../../shared/widgets/icon_avatar.dart';
import '../../../../l10n/l10n.dart';

class MaisPage extends StatelessWidget {
  const MaisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = context.watch<UserContextProvider>().userRole;
    final podeVerCargaDocente =
        role == null ||
        kNavigationItems
            .firstWhere((item) => item.route == AppRoutes.cargaDocente)
            .isAvailableFor(role);
    final avisos = [
      for (final aviso in context.watch<MuralController>().avisosVisiveis(role))
        NotificacaoModel(
          titulo: aviso.titulo,
          subtitulo: aviso.conteudo,
          icone: aviso.modelo.icone,
        ),
    ];
    final avisoPrincipal = avisos.isEmpty ? null : avisos.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _AvisosCard(
          aviso: avisoPrincipal,
          onVerTodos: () => _showAvisos(context, avisos),
        ),
        const SizedBox(height: 24),
        _SectionTitle(icon: SigadIcons.raio, title: l10n.acessoRapido),
        const SizedBox(height: 12),
        _QuickAccessGrid(
          items: [
            if (podeVerCargaDocente)
              _QuickAccessItem(
                icon: SigadIcons.aula,
                label: l10n.navCargaDocente,
                description: l10n.maisCargaDocenteDesc,
                route: AppRoutes.cargaDocente,
              ),
            _QuickAccessItem(
              icon: SigadIcons.grupo,
              label: l10n.navProfessores,
              description: l10n.maisProfessoresDesc,
              route: AppRoutes.professores,
            ),
            _QuickAccessItem(
              icon: SigadIcons.laboratorio,
              label: l10n.navLaboratorios,
              description: l10n.maisLaboratoriosDesc,
              route: AppRoutes.aulasPraticas,
            ),
            _QuickAccessItem(
              icon: SigadIcons.eventoConfirmado,
              label: l10n.maisReunioes,
              description: l10n.maisReunioesDesc,
              route: AppRoutes.calendario,
            ),
            _QuickAccessItem(
              icon: SigadIcons.demanda,
              label: l10n.navDemandas,
              description: l10n.maisDemandasDesc,
              route: AppRoutes.demandas,
            ),
            _QuickAccessItem(
              icon: SigadIcons.aviso,
              label: l10n.maisNoticias,
              description: l10n.maisNoticiasDesc,
              route: AppRoutes.batePapo,
            ),
            _QuickAccessItem(
              icon: SigadIcons.graficoBarras,
              label: l10n.navRelatorios,
              description: l10n.maisRelatoriosDesc,
              route: AppRoutes.relatorios,
            ),
            _QuickAccessItem(
              icon: SigadIcons.professor,
              label: l10n.maisCursos,
              description: l10n.maisCursosDesc,
              route: AppRoutes.atividades,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionTitle(
          icon: SigadIcons.escudoVerificado,
          title: l10n.maisAdministracao,
        ),
        const SizedBox(height: 12),
        _AdminCard(
          items: [
            _AdminItem(
              icon: SigadIcons.calendario,
              title: l10n.maisAgendaIntegrada,
              subtitle: l10n.maisAgendaIntegradaDesc,
              route: AppRoutes.calendario,
            ),
            _AdminItem(
              icon: SigadIcons.configuracoes,
              title: l10n.navConfiguracoes,
              subtitle: l10n.maisConfiguracoesDesc,
              route: AppRoutes.configuracoes,
            ),
            _AdminItem(
              icon: SigadIcons.ajuda,
              title: l10n.maisAjuda,
              subtitle: l10n.maisAjudaDesc,
              onTap: () => _showAjuda(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SuporteCard(),
      ],
    );
  }

  void _showAvisos(BuildContext context, List<NotificacaoModel> avisos) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.maisAvisosImportantes,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (avisos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(context.l10n.maisNenhumAviso)),
              )
            else
              ...avisos.map(
                (aviso) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SigadIcon(aviso.icone, color: SigadColors.brand),
                  title: Text(aviso.titulo),
                  subtitle: Text(aviso.subtitulo),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAjuda(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.maisCentralAjuda),
        content: Text(context.l10n.maisCentralAjudaMensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.fechar),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SigadIcon(icon, color: SigadColors.brand, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _AvisosCard extends StatelessWidget {
  const _AvisosCard({required this.aviso, required this.onVerTodos});

  final NotificacaoModel? aviso;
  final VoidCallback onVerTodos;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: SigadColors.brandLight,
                  shape: BoxShape.circle,
                ),
                child: const SigadIcon(
                  SigadIcons.aviso,
                  color: SigadColors.brand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    Text(
                      context.l10n.maisAvisosImportantes,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SigadColors.brand,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        context.l10n.maisDepartamento,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            aviso == null
                ? context.l10n.maisNenhumAviso
                : '${aviso!.titulo}. ${aviso!.subtitulo}.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(height: 28),
          InkWell(
            onTap: onVerTodos,
            child: Row(
              children: [
                Text(
                  context.l10n.maisVerTodosAvisos,
                  style: TextStyle(
                    color: SigadColors.brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const SigadIcon(
                  SigadIcons.chevronDireita,
                  color: SigadColors.brand,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessItem {
  const _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String description;
  final String route;
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.items});

  final List<_QuickAccessItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(14) > 19;
        final crossAxisCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 320 && !largeText
            ? 3
            : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: constraints.maxWidth >= 640
                ? 136
                : largeText
                ? 140
                : 108,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _QuickAccessCard(item: item, tone: sigadToneForIndex(index));
          },
        );
      },
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({required this.item, required this.tone});

  final _QuickAccessItem item;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 170;
        return Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).pushReplacementNamed(item.route),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tone.withValues(alpha: 0.18)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SigadIconAvatar(
                    icon: item.icon,
                    tone: tone,
                    size: 34,
                    iconSize: 18,
                    borderRadius: 11,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AdminItem {
  const _AdminItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final VoidCallback? onTap;
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({required this.items});

  final List<_AdminItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _AdminTile(item: items[i], tone: sigadToneForIndex(i)),
            if (i < items.length - 1)
              Divider(height: 1, color: colors.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({required this.item, required this.tone});

  final _AdminItem item;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SigadIconAvatar(icon: item.icon, tone: tone),
      title: Text(
        item.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(item.subtitle),
      trailing: const SigadIcon(SigadIcons.chevronDireita),
      onTap:
          item.onTap ??
          () => Navigator.of(context).pushReplacementNamed(item.route!),
    );
  }
}

class _SuporteCard extends StatelessWidget {
  const _SuporteCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SigadColors.brandLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;
          final text = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: SigadIcon(SigadIcons.suporte, color: SigadColors.brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.maisPrecisaSuporte,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      context.l10n.maisFaleComTi,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final button = OutlinedButton.icon(
            onPressed: () => _abrirChamado(context),
            icon: const SigadIcon(SigadIcons.abrirExterno, size: 18),
            label: Text(context.l10n.maisAbrirChamado),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [text, const SizedBox(height: 12), button],
            );
          }
          return Row(
            children: [
              Expanded(child: text),
              const SizedBox(width: 12),
              button,
            ],
          );
        },
      ),
    );
  }

  Future<void> _abrirChamado(BuildContext context) async {
    final uri = Uri.parse('mailto:suporte.ti@exemplo.edu.br');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
