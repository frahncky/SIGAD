import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_runtime_config.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import 'app_event_logger.dart';
import 'auth_session_repository.dart';

/// Gerencia o estado do usuário autenticado da aplicação
class UserContextProvider extends ChangeNotifier {
  UserContextProvider({
    AuthSessionRepository? sessionRepository,
    DateTime Function()? now,
  }) : _sessionRepository = sessionRepository ?? AuthSessionRepository(),
       _now = now ?? DateTime.now;

  final DateTime Function() _now;
  Timer? _expiryTimer;
  User? _currentUser;
  final AuthSessionRepository _sessionRepository;
  String? _sessionToken;
  DateTime? _sessionExpiresAt;
  bool _sessionRestored = false;

  User? get currentUser => isAuthenticated ? _currentUser : null;
  UserRole? get userRole => currentUser?.role;
  String? get sessionToken => null; // Demo has no API credential.
  DateTime? get sessionExpiresAt => _sessionExpiresAt;
  bool get isSessionRestored => _sessionRestored;
  bool get requiresReauthentication =>
      _sessionExpiresAt != null && !_sessionExpiresAt!.isAfter(_now());

  bool get isAuthenticated =>
      AppRuntimeConfig.allowLocalDemo &&
      _currentUser != null &&
      !requiresReauthentication;

  /// Abre somente a demonstração local. Não autentica credenciais remotas.
  Future<void> login(User user, {String? sessionToken}) async {
    if (!AppRuntimeConfig.allowLocalDemo) {
      throw StateError('Autenticação institucional não integrada.');
    }
    final expiry = _now().add(const Duration(hours: 8));
    await _sessionRepository.save(
      user: user,
      sessionToken: 'local_demo',
      expiresAt: expiry,
    );
    _currentUser = user;
    _sessionToken = 'local_demo';
    _sessionExpiresAt = expiry;
    _scheduleExpiry();
    AppEventLogger.action(
      'session_login_persisted',
      details: {'userRef': _userRef(user.id), 'role': user.role.name},
    );
    notifyListeners();
  }

  /// Realiza logout do usuário
  Future<void> logout() async {
    _expiryTimer?.cancel();
    _currentUser = null;
    _sessionToken = null;
    _sessionExpiresAt = null;
    try {
      await _sessionRepository.clear();
      AppEventLogger.action('session_logout_cleared');
    } finally {
      notifyListeners();
    }
  }

  /// Atualiza o perfil do usuário autenticado
  Future<void> updateUser(User user) async {
    if (!isAuthenticated) throw StateError('Sessão expirada.');
    _currentUser = user;
    final token = _sessionToken;
    final expiresAt = _sessionExpiresAt;
    if (token != null) {
      try {
        await _sessionRepository.save(
          user: user,
          sessionToken: token,
          expiresAt: expiresAt,
        );
      } catch (error, stackTrace) {
        AppEventLogger.error(
          'session_update_persist_error',
          error,
          stackTrace: stackTrace,
        );
      }
    }
    notifyListeners();
  }

  Future<void> restoreSession() async {
    if (_sessionRestored) return;

    final data = await _sessionRepository.load();
    if (data != null) {
      if (!data.expiresAt.isAfter(_now())) {
        await _sessionRepository.clear();
        AppEventLogger.action('session_restore_expired');
      } else {
        _currentUser = data.user;
        _sessionToken = data.sessionToken;
        _sessionExpiresAt = data.expiresAt;
        _scheduleExpiry();
        AppEventLogger.action(
          'session_restore_success',
          details: {
            'userRef': _userRef(data.user.id),
            'role': data.user.role.name,
          },
        );
      }
    }

    _sessionRestored = true;
    notifyListeners();
  }

  Future<void> refreshSession() async {
    if (!AppRuntimeConfig.allowLocalDemo || !isAuthenticated) {
      throw StateError('É necessário entrar novamente.');
    }
    final user = _currentUser;
    final token = _sessionToken;
    if (user == null || token == null) return;

    _sessionExpiresAt = _now().add(const Duration(hours: 8));
    await _sessionRepository.save(
      user: user,
      sessionToken: token,
      expiresAt: _sessionExpiresAt,
    );
    _scheduleExpiry();
    AppEventLogger.action(
      'session_refresh_success',
      details: {'userRef': _userRef(user.id)},
    );
    notifyListeners();
  }

  /// Verifica se o usuário atual tem uma role específica
  bool hasRole(UserRole role) {
    return currentUser?.role == role;
  }

  /// Verifica se o usuário atual tem uma das roles informadas
  bool hasAnyRole(Set<UserRole> roles) {
    if (!isAuthenticated) return false;
    return roles.contains(_currentUser!.role);
  }

  void _scheduleExpiry() {
    _expiryTimer?.cancel();
    final expiresAt = _sessionExpiresAt;
    if (expiresAt == null || !hasListeners) return;
    _expiryTimer = Timer(expiresAt.difference(_now()), () {
      _currentUser = null;
      _sessionToken = null;
      notifyListeners();
    });
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _scheduleExpiry();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) _expiryTimer?.cancel();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  String _userRef(String userId) {
    final normalized = userId.trim();
    if (normalized.isEmpty) return 'unknown';
    if (normalized.length <= 6) return normalized;
    return '${normalized.substring(0, 2)}***${normalized.substring(normalized.length - 2)}';
  }
}
