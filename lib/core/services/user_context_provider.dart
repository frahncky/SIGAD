import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_role.dart';
import 'app_event_logger.dart';
import 'auth_session_repository.dart';

/// Gerencia o estado do usuário autenticado da aplicação
class UserContextProvider extends ChangeNotifier {
  UserContextProvider({AuthSessionRepository? sessionRepository})
    : _sessionRepository = sessionRepository ?? AuthSessionRepository();

  User? _currentUser;
  final AuthSessionRepository _sessionRepository;
  String? _sessionToken;
  DateTime? _sessionExpiresAt;
  bool _sessionRestored = false;

  User? get currentUser => _currentUser;
  UserRole? get userRole => _currentUser?.role;
  String? get sessionToken => _sessionToken;
  DateTime? get sessionExpiresAt => _sessionExpiresAt;
  bool get isSessionRestored => _sessionRestored;
  bool get requiresReauthentication =>
      _sessionExpiresAt != null && _sessionExpiresAt!.isBefore(DateTime.now());

  bool get isAuthenticated => _currentUser != null;

  /// Realiza login do usuário
  Future<void> login(User user, {String? sessionToken}) async {
    _currentUser = user;
    _sessionToken =
        sessionToken ?? 'local_${DateTime.now().millisecondsSinceEpoch}';
    _sessionExpiresAt = DateTime.now().add(const Duration(hours: 8));
    await _sessionRepository.save(
      user: user,
      sessionToken: _sessionToken!,
      expiresAt: _sessionExpiresAt,
    );
    AppEventLogger.action(
      'session_login_persisted',
      details: {'userRef': _userRef(user.id), 'role': user.role.name},
    );
    notifyListeners();
  }

  /// Realiza logout do usuário
  Future<void> logout() async {
    _currentUser = null;
    _sessionToken = null;
    _sessionExpiresAt = null;
    await _sessionRepository.clear();
    AppEventLogger.action('session_logout_cleared');
    notifyListeners();
  }

  /// Atualiza o perfil do usuário autenticado
  Future<void> updateUser(User user) async {
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
      if (data.expiresAt.isBefore(DateTime.now())) {
        await _sessionRepository.clear();
        AppEventLogger.action('session_restore_expired');
      } else {
        _currentUser = data.user;
        _sessionToken = data.sessionToken;
        _sessionExpiresAt = data.expiresAt;
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
    final user = _currentUser;
    final token = _sessionToken;
    if (user == null || token == null) return;

    _sessionExpiresAt = DateTime.now().add(const Duration(hours: 8));
    await _sessionRepository.save(
      user: user,
      sessionToken: token,
      expiresAt: _sessionExpiresAt,
    );
    AppEventLogger.action(
      'session_refresh_success',
      details: {'userRef': _userRef(user.id)},
    );
    notifyListeners();
  }

  /// Verifica se o usuário atual tem uma role específica
  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  /// Verifica se o usuário atual tem uma das roles informadas
  bool hasAnyRole(Set<UserRole> roles) {
    if (_currentUser == null) return false;
    return roles.contains(_currentUser!.role);
  }

  String _userRef(String userId) {
    final normalized = userId.trim();
    if (normalized.isEmpty) return 'unknown';
    if (normalized.length <= 6) return normalized;
    return '${normalized.substring(0, 2)}***${normalized.substring(normalized.length - 2)}';
  }
}
