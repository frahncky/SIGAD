import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/sigad_icon.dart';
import '../../../../app/theme/sigad_icons.dart';
import '../../../../core/models/user.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/security/authorization_policy.dart';
import '../../../../core/services/app_event_logger.dart';
import '../../../../core/services/app_feedback_service.dart';
import '../../../../core/services/greeting_name_provider.dart';
import '../../../../core/services/locale_provider.dart';
import '../../../../core/services/theme_provider.dart';
import '../../../../core/services/user_context_provider.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/page_status_view.dart';
import '../../../../shared/widgets/sigad_sheet.dart';
import '../../../../shared/widgets/work_item_ui.dart';
import '../../data/configuracoes_repository.dart';
import '../../domain/app_versao.dart';
import '../greeting_name_dialog.dart';

/// Preferências do usuário e informações da conta.
///
/// O estado exibido vem dos providers ([ThemeProvider], [LocaleProvider],
/// [GreetingNameProvider], [UserContextProvider]). A tela não guarda uma
/// cópia das configurações: ao alterar uma preferência, grava somente aquele
/// campo a partir do valor atual do armazenamento, sem apagar o que outras
/// partes do app gravaram na mesma chave (como os convites da agenda).
class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key, this.repository, this.versao});

  /// Onde as preferências são gravadas. Padrão: [ConfiguracoesRepository].
  final ConfiguracoesRepository? repository;

  /// Versão exibida em "Sobre". Padrão: [AppVersao.atual].
  final String? versao;

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  late final ConfiguracoesRepository _repository =
      widget.repository ?? ConfiguracoesRepository();

  String? get _versao => widget.versao ?? AppVersao.atual;

  Future<void> _salvarPreferencias({
    bool? modoDark,
    String? tamanhoFonte,
    String? idioma,
  }) async {
    try {
      await _repository.salvarPreferencias(
        modoDark: modoDark,
        tamanhoFonte: tamanhoFonte,
        idioma: idioma,
      );
    } catch (error, stackTrace) {
      AppEventLogger.error(
        'configuracoes_save_error',
        error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      AppFeedbackService.error(context, context.l10n.erroSalvar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userContext = context.watch<UserContextProvider>();
    final role = userContext.userRole;
    if (!AuthorizationPolicy.canAccessConfiguracoes(role)) {
      return PageStatusView(
        icon: SigadIcons.cadeado,
        title: context.l10n.facaLogin,
      );
    }
    final l10n = context.l10n;
    final usuario = userContext.currentUser;
    final tema = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>();
    final greeting = context.watch<GreetingNameProvider>();
    final versao = _versao;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _ConfigSection(
          titulo: l10n.minhaConta,
          children: [
            _ContaResumo(usuario: usuario, role: role),
            ListTile(
              leading: const _IconeLinha(SigadIcons.pessoa),
              title: Text(greetingNameLabel(context)),
              subtitle: Text(greeting.displayName),
              trailing: const _IconeLinha(SigadIcons.editar),
              enabled: usuario != null && !greeting.loading,
              onTap: () async {
                final saved = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => GreetingNameDialog(preference: greeting),
                );
                if (saved == true && context.mounted) {
                  AppFeedbackService.success(
                    context,
                    context.l10n.nomeSaudacaoSalvo,
                  );
                }
              },
            ),
          ],
        ),
        _ConfigSection(
          titulo: l10n.aparenciaLeitura,
          children: [
            SwitchListTile(
              secondary: const _IconeLinha(SigadIcons.lua),
              title: Text(l10n.modoNoturno),
              subtitle: Text(l10n.modoNoturnoSub),
              value: tema.isDark,
              onChanged: (value) {
                context.read<ThemeProvider>().setDark(value);
                _salvarPreferencias(modoDark: value);
              },
            ),
            _ConfigSelector(
              icon: SigadIcons.texto,
              titulo: l10n.tamanhoTexto,
              valor: tema.tamanhoTexto,
              opcoes: ThemeProvider.tamanhosTexto.keys.toList(growable: false),
              rotulo: (opcao) => switch (opcao) {
                'Normal' => l10n.tamanhoNormal,
                'Grande' => l10n.tamanhoGrande,
                'Muito grande' => l10n.tamanhoMuitoGrande,
                _ => l10n.tamanhoMedio,
              },
              onChanged: (valor) {
                context.read<ThemeProvider>().setTamanhoTexto(valor);
                _salvarPreferencias(tamanhoFonte: valor);
              },
            ),
            _ConfigSelector(
              icon: SigadIcons.idioma,
              titulo: l10n.idioma,
              valor: locale.idioma,
              opcoes: LocaleProvider.opcoes,
              rotulo: (opcao) => opcao == LocaleProvider.automatico
                  ? l10n.idiomaAutomatico
                  : opcao,
              onChanged: (valor) {
                context.read<LocaleProvider>().setIdioma(valor);
                _salvarPreferencias(idioma: valor);
              },
            ),
          ],
        ),
        if (AuthorizationPolicy.canManageMural(role))
          _ConfigSection(
            titulo: l10n.departamento,
            children: [
              _ConfigItem(
                icon: SigadIcons.aviso,
                titulo: l10n.navMural,
                subtitulo: l10n.muralDepartamentoSub,
                onTap: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.mural),
              ),
            ],
          ),
        _ConfigSection(
          titulo: l10n.sobre,
          children: [
            _ConfigItem(
              icon: SigadIcons.info,
              titulo: l10n.sobreSigad,
              subtitulo: versao == null ? null : l10n.versaoBuild(versao),
              onTap: () => _showSobre(context, versao),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _BotaoSair(onPressed: () => _showConfirmacaoLogout(context)),
      ],
    );
  }

  void _showSobre(BuildContext context, String? versao) {
    final l10n = context.l10n;
    showSigadSheet<void>(
      context: context,
      builder: (sheetContext) => SigadSheetFrame(
        title: l10n.sobreSigad,
        closeTooltip: l10n.fecharSobre,
        onClose: () => Navigator.pop(sheetContext),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ativo oficial do aplicativo; decorativo (o título já diz SIGAD).
            ExcludeSemantics(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 64,
                    height: 64,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (versao != null) DetailRow(label: l10n.versao, value: versao),
            DetailRow(
              label: l10n.desenvolvidoPor,
              value: l10n.equipeDesenvolvimento,
            ),
            Text(
              l10n.sobreDescricao,
              style: Theme.of(sheetContext).textTheme.bodyMedium,
            ),
          ],
        ),
        footer: ElevatedButton(
          onPressed: () => Navigator.pop(sheetContext),
          child: Text(l10n.fechar),
        ),
      ),
    );
  }

  void _showConfirmacaoLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.sair),
        content: Text(dialogContext.l10n.sairPergunta),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(dialogContext.l10n.cancelar),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: corRisco(dialogContext),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<UserContextProvider>().logout();
              if (!context.mounted) return;
              await Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
            },
            child: Text(dialogContext.l10n.sair),
          ),
        ],
      ),
    );
  }
}

/// Ícone das linhas, sempre no mesmo tom (a cor não carrega significado).
class _IconeLinha extends StatelessWidget {
  const _IconeLinha(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SigadIcon(icon, color: Theme.of(context).colorScheme.primary);
  }
}

/// Seção com título discreto e cartão de linhas separadas por divisórias.
class _ConfigSection extends StatelessWidget {
  const _ConfigSection({required this.titulo, required this.children});

  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Semantics(
              header: true,
              child: Text(
                titulo,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Material(
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: colors.outlineVariant,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dados da conta autenticada em bloco compacto (somente leitura).
class _ContaResumo extends StatelessWidget {
  const _ContaResumo({required this.usuario, required this.role});

  final User? usuario;
  final UserRole? role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final nome = usuario?.name.trim() ?? '';
    final secundario = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: CircleAvatar(
                radius: 20,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  nome.isEmpty ? '?' : nome[0].toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
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
                    nome.isEmpty ? '—' : nome,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(usuario?.email ?? '—', style: secundario),
                  Text(role?.nomeEm(context.l10n) ?? '—', style: secundario),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigItem extends StatelessWidget {
  const _ConfigItem({
    required this.icon,
    required this.titulo,
    required this.onTap,
    this.subtitulo,
  });

  final IconData icon;
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconeLinha(icon),
      title: Text(titulo),
      subtitle: subtitulo == null ? null : Text(subtitulo!),
      trailing: SigadIcon(
        SigadIcons.chevronDireita,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

/// Linha que mostra a opção escolhida e abre a lista de opções em um sheet.
///
/// O leitor de tela anuncia o nome da configuração e a opção atual; a lista
/// usa itens de rádio com texto em tamanho de leitura e alvo de 48dp ou mais.
class _ConfigSelector extends StatelessWidget {
  const _ConfigSelector({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.opcoes,
    required this.rotulo,
    required this.onChanged,
  });

  final IconData icon;
  final String titulo;
  final String valor;
  final List<String> opcoes;
  final ValueChanged<String> onChanged;

  /// Texto exibido para cada opção (o valor salvo continua o mesmo).
  final String Function(String opcao) rotulo;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconeLinha(icon),
      title: Text(titulo),
      subtitle: Text(rotulo(valor)),
      trailing: SigadIcon(
        SigadIcons.chevronDireita,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: () => _abrirOpcoes(context),
    );
  }

  void _abrirOpcoes(BuildContext context) {
    final l10n = context.l10n;
    showSigadSheet<void>(
      context: context,
      builder: (sheetContext) => SigadSheetFrame(
        title: titulo,
        closeTooltip: l10n.fechar,
        onClose: () => Navigator.pop(sheetContext),
        body: RadioGroup<String>(
          groupValue: valor,
          onChanged: (novo) {
            Navigator.pop(sheetContext);
            if (novo != null && novo != valor) onChanged(novo);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final opcao in opcoes)
                RadioListTile<String>(
                  value: opcao,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    rotulo(opcao),
                    style: Theme.of(sheetContext).textTheme.bodyLarge,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ação de saída em contorno na cor de risco (a confirmação vem a seguir).
class _BotaoSair extends StatelessWidget {
  const _BotaoSair({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final risco = corRisco(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const SigadIcon(SigadIcons.sair),
      label: Text(context.l10n.sairDaConta),
      style: OutlinedButton.styleFrom(
        foregroundColor: risco,
        side: BorderSide(color: risco),
        minimumSize: const Size.fromHeight(52),
      ),
    );
  }
}
