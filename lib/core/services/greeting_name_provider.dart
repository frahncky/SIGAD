import 'dart:async';
import 'package:flutter/foundation.dart';
import 'greeting_name_repository.dart';
import 'user_context_provider.dart';

class GreetingNameProvider extends ChangeNotifier {
  GreetingNameProvider(this._users, {GreetingNameRepository? repository})
    : _repository = repository ?? GreetingNameRepository() {
    _users.addListener(_accountChanged);
    _accountChanged();
  }

  final UserContextProvider _users;
  final GreetingNameRepository _repository;
  String? _userId;
  String? _name;
  bool _loading = false;
  bool _saving = false;
  bool _disposed = false;
  int _generation = 0;

  String? get customName => _name;
  String? get userId => _userId;
  bool get loading => _loading;
  bool get saving => _saving;
  String get displayName =>
      _name ??
      (_users.currentUser?.name.trim().split(RegExp(r'\s+')).first ?? '');

  void _accountChanged() {
    final id = _users.currentUser?.id;
    if (id == _userId) return;
    _userId = id;
    _name = null;
    _saving = false;
    _loading = id != null;
    final generation = ++_generation;
    notifyListeners();
    if (id != null) unawaited(_load(id, generation));
  }

  Future<void> _load(String id, int generation) async {
    String? name;
    try {
      name = await _repository.load(id);
    } catch (_) {
      // Uma leitura indisponível usa o nome da conta, sem expor dados em logs.
    }
    if (_disposed || generation != _generation) return;
    _name = name;
    _loading = false;
    notifyListeners();
  }

  Future<void> save(String value, {String? expectedUserId}) async {
    final id = _userId;
    if (id == null ||
        _users.currentUser?.id != id ||
        (expectedUserId != null && expectedUserId != id)) {
      throw StateError('Sessão indisponível.');
    }
    if (_saving || _loading) throw StateError('Operação em andamento.');
    final generation = _generation;
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    final name = normalized.isEmpty ? null : normalized;
    _saving = true;
    notifyListeners();
    try {
      await _repository.save(id, name);
      if (_disposed ||
          generation != _generation ||
          _users.currentUser?.id != id) {
        throw StateError('A conta foi alterada.');
      }
      _name = name;
    } finally {
      if (!_disposed && generation == _generation) {
        _saving = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _users.removeListener(_accountChanged);
    super.dispose();
  }
}
