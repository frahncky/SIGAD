import 'package:flutter/material.dart';
import 'user_role.dart';

class NavigationItem {
  const NavigationItem({
    required this.route,
    required this.label,
    required this.icon,
    this.subtitle,
    this.availableFor,
  });

  final String route;
  final String label;
  final IconData icon;
  final String? subtitle;
  final Set<UserRole>? availableFor;

  bool isAvailableFor(UserRole role) {
    if (availableFor == null) return true;
    return availableFor!.contains(role);
  }
}
