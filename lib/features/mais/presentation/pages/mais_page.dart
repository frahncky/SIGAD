import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_colors.dart';
import '../../../../app/theme/sigad_tone_palette.dart';
import '../../../../core/services/notificacoes_service.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../shared/widgets/icon_avatar.dart';

class MaisPage extends StatelessWidget {
  const MaisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserContextProvider>().userRole;
    final avisos = NotificacoesService.porRole(role);
    final avisoPrincipal = avisos.isEmpty ? null : avisos.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _AvisosCard(
          aviso: avisoPrincipal,
          onVerTodos: () => _showAvisos(context, avisos),
        ),
        const SizedBox(height: 24),
        const _SectionTitle(icon: Icons.bolt_outlined, title: 'Acesso rápido'),
        const SizedBox(height: 12),
        _QuickAccessGrid(
          items: [
            _QuickAccessItem(
              icon: Icons.co_present_outlined,
              label: 'Carga docente',
              description: 'Planeje e acompanhe a carga horária.',
              route: AppRoutes.cargaDocente,
            ),
            _QuickAccessItem(
              icon: Icons.groups_outlined,
              label: 'Professores',
              description: 'Gerencie docentes do departamento.',
              route: AppRoutes.professores,
            ),
            _QuickAccessItem(
              icon: Icons.science_outlined,
              label: 'Laboratórios',
              description: 'Recursos, reservas e ocupação.',
              route: AppRoutes.aulasPraticas,
            ),
            _QuickAccessItem(
              icon: Icons.event_available_outlined,
              label: 'Reuniões',
              description: 'Pautas, atas e participantes.',
              route: AppRoutes.calendario,
            ),
            _QuickAccessItem(
              icon: Icons.assignment_outlined,
              label: 'Demandas',
              description: 'Acompanhe e gerencie solicitações.',
              route: AppRoutes.demandas,
            ),
            _QuickAccessItem(
              icon: Icons.campaign_outlined,
              label: 'Notícias',
              description: 'Comunicados e informativos.',
              route: AppRoutes.batePapo,
            ),
            _QuickAccessItem(
              icon: Icons.bar_chart_rounded,
              label: 'Relatórios',
              description: 'Indicadores e dados do departamento.',
              route: AppRoutes.relatorios,
            ),
            _QuickAccessItem(
              icon: Icons.school_outlined,
              label: 'Cursos',
              description: 'Disciplinas e ofertas acadêmicas.',
              route: AppRoutes.atividades,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionTitle(
          icon: Icons.verified_user_outlined,
          title: 'Administração',
        ),
        const SizedBox(height: 12),
        _AdminCard(
          items: [
            _AdminItem(
              icon: Icons.calendar_month_outlined,
              title: 'Agenda integrada',
              subtitle: 'Visualize eventos e compromissos do departamento.',
              route: AppRoutes.calendario,
            ),
            _AdminItem(
              icon: Icons.settings_outlined,
              title: 'Configurações',
              subtitle: 'Personalize preferências do aplicativo.',
              route: AppRoutes.configuracoes,
            ),
            _AdminItem(
              icon: Icons.help_outline_rounded,
              title: 'Ajuda',
              subtitle: 'Central de ajuda, tutoriais e suporte.',
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
              'Avisos importantes',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (avisos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Nenhum aviso no momento.')),
              )
            else
              ...avisos.map(
                (aviso) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(aviso.icone, color: SigadColors.brand),
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
        title: const Text('Central de ajuda'),
        content: const Text(
          'Tutoriais e suporte estarão disponíveis em breve. '
          'Para dúvidas urgentes, abra um chamado com a equipe de TI do campus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
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
        Icon(icon, color: SigadColors.brand, size: 22),
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
                child: const Icon(
                  Icons.campaign_outlined,
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
                      'Avisos importantes',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
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
                      child: const Text(
                        'DEPARTAMENTO',
                        style: TextStyle(
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
                ? 'Nenhum aviso no momento.'
                : '${aviso!.titulo}. ${aviso!.subtitulo}.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(height: 28),
          InkWell(
            onTap: onVerTodos,
            child: Row(
              children: [
                Text(
                  'Ver todos os avisos',
                  style: TextStyle(
                    color: SigadColors.brand,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: SigadColors.brand),
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
        final crossAxisCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 640
            ? 3
            : constraints.maxWidth >= 340
            ? 4
            : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 172,
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
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () =>
            Navigator.of(context).pushReplacementNamed(item.route),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tone.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SigadIconAvatar(
                icon: item.icon,
                tone: tone,
                size: 34,
                iconSize: 18,
                borderRadius: 11,
              ),
              const Spacer(),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
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
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
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
      trailing: const Icon(Icons.chevron_right_rounded),
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
                child: Icon(Icons.headset_mic_outlined, color: SigadColors.brand),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precisando de suporte?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Fale com a equipe de TI do campus.',
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
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('Abrir chamado'),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [text, const SizedBox(height: 12), button],
            );
          }
          return Row(children: [Expanded(child: text), const SizedBox(width: 12), button]);
        },
      ),
    );
  }

  Future<void> _abrirChamado(BuildContext context) async {
    final uri = Uri.parse('mailto:suporte.ti@ifma.edu.br');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
