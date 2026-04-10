import 'package:flutter/material.dart';

class NavigationItem {
  const NavigationItem({
    required this.route,
    required this.label,
    required this.icon,
    this.subtitle,
  });

  final String route;
  final String label;
  final IconData icon;
  final String? subtitle;
}
