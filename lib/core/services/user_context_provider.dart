import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/user_role.dart';

/// Gerencia o estado do usuário autenticado da aplicação
class UserContextProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  UserRole? get userRole => _currentUser?.role;

  bool get isAuthenticated => _currentUser != null;

  /// Realiza login do usuário
  Future<void> login(User user) async {
    _currentUser = user;
    notifyListeners();
  }

  /// Realiza logout do usuário
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  /// Atualiza o perfil do usuário autenticado
  void updateUser(User user) {
    _currentUser = user;
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
}
