/// Versão do aplicativo em execução.
///
/// A ferramenta Flutter (`flutter run`/`flutter build`) define
/// `FLUTTER_BUILD_NAME` e `FLUTTER_BUILD_NUMBER` a partir do campo `version`
/// do `pubspec.yaml` ou das opções `--build-name`/`--build-number`. São as
/// mesmas constantes expostas pelo SDK como `appBuildName`/`appBuildNumber`.
/// Quando não forem definidas, a versão não é exibida (nada é inventado).
abstract final class AppVersao {
  static const String? _nome = bool.hasEnvironment('FLUTTER_BUILD_NAME')
      ? String.fromEnvironment('FLUTTER_BUILD_NAME')
      : null;
  static const String? _numero = bool.hasEnvironment('FLUTTER_BUILD_NUMBER')
      ? String.fromEnvironment('FLUTTER_BUILD_NUMBER')
      : null;

  /// Versão desta compilação, ou `null` se a ferramenta não a informou.
  static String? get atual => formatar(nome: _nome, numero: _numero);

  /// Monta o texto exibido: `1.0.0 (1)`, `1.0.0` ou `null`.
  static String? formatar({String? nome, String? numero}) {
    final n = nome?.trim() ?? '';
    if (n.isEmpty) return null;
    final b = numero?.trim() ?? '';
    return b.isEmpty ? n : '$n ($b)';
  }
}
