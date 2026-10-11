import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigad/core/services/local_storage_service.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/shared_preferences');
  final calls = <String>[];

  setUp(() {
    SharedPreferences.resetStatic();
    calls.clear();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call.method);
      if (call.method.startsWith('getAll')) return <String, Object>{};
      return false;
    });
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    SharedPreferences.resetStatic();
  });

  test('falha de gravação de lista é propagada', () async {
    await expectLater(
      LocalStorageService.saveList('items', [
        {'id': 'one'},
      ]),
      throwsStateError,
    );
    expect(calls, contains('setString'));
  });

  test('falha de gravação de mapa é propagada', () async {
    await expectLater(
      LocalStorageService.saveMap('session', {'sessionKind': 'demo'}),
      throwsStateError,
    );
    expect(calls, contains('setString'));
  });

  test('falha de remoção é propagada', () async {
    await expectLater(LocalStorageService.remove('session'), throwsStateError);
    expect(calls, contains('remove'));
  });
}
