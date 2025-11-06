import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const DetailsPage({super.key, required this.title, required this.subtitle, this.children = const []});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.primary.withOpacity(0.12)),
            ),
            child: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
