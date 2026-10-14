import 'package:flutter/material.dart';
import '../../../core/services/greeting_name_provider.dart';
import '../../../l10n/l10n.dart';

String greetingNameLabel(BuildContext context) => context.l10n.nomeSaudacao;

class GreetingNameDialog extends StatefulWidget {
  const GreetingNameDialog({super.key, required this.preference});
  final GreetingNameProvider preference;

  @override
  State<GreetingNameDialog> createState() => _GreetingNameDialogState();
}

class _GreetingNameDialogState extends State<GreetingNameDialog> {
  late final _controller = TextEditingController(
    text: widget.preference.customName,
  );
  late final String? _userId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _userId = widget.preference.userId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.preference.save(_controller.text, expectedUserId: _userId);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = context.l10n.nomeSaudacaoErro;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: AlertDialog(
        scrollable: true,
        title: Text(greetingNameLabel(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.nomeSaudacaoAjuda),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              enabled: !_saving,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              minLines: 1,
              decoration: InputDecoration(
                labelText: greetingNameLabel(context),
              ),
              onSubmitted: (_) => _save(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: Text(context.l10n.cancelar),
          ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _saving ? context.l10n.nomeSaudacaoSalvando : context.l10n.salvar,
            ),
          ),
        ],
      ),
    );
  }
}
