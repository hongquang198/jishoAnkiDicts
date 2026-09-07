import 'package:flutter/material.dart';

/// Pink section title shared by the dictionary detail screens.
///
/// Replaces the repeated hardcoded `Text` style (DB8C8A, bold, 20) with and
/// without a leading icon so section headings stay consistent.
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      title,
      style: const TextStyle(
        color: Color(0xffDB8C8A),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
    final iconData = icon;
    if (iconData == null) return label;
    return Row(
      children: [
        Icon(iconData, color: const Color(0xffDB8C8A), size: 20),
        const SizedBox(width: 6),
        label,
      ],
    );
  }
}
