import 'package:flutter/material.dart';

import '../../app/theme/sigad_colors.dart';

abstract final class AppFeedbackService {
  static void info(BuildContext context, String message) {
    _show(context, message, background: SigadColors.ink);
  }

  static void success(BuildContext context, String message) {
    _show(context, message, background: SigadColors.success);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message, background: SigadColors.warning);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, background: SigadColors.risk);
  }

  static void _show(BuildContext context, String message, {required Color background}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: background,
        ),
      );
  }
}
