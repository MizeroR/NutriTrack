import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool showDivider;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Column(children: children),
        if (showDivider) ...[
          const SizedBox(height: 8),
          const Divider(color: Colors.black, thickness: 1, height: 20),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}
