import "package:flutter/material.dart";

class StatusChip extends StatelessWidget {
  final String text;
  const StatusChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final t = text.trim().toLowerCase();
    IconData icon = Icons.info_outline;

    if (t.contains("active") || t.contains("online") || t.contains("running")) icon = Icons.check_circle_outline;
    if (t.contains("expired") || t.contains("error") || t.contains("failed")) icon = Icons.error_outline;

    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      visualDensity: VisualDensity.compact,
    );
  }
}