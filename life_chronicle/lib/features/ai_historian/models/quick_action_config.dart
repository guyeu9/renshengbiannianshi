import 'package:flutter/material.dart';

class QuickActionConfig {
  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;
  final String analysisType;
  final String queryTemplate;

  const QuickActionConfig({
    required this.id,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.analysisType,
    required this.queryTemplate,
  });
}
