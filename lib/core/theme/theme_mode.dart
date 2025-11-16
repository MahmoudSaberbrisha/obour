import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/app_localizations.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void set(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeToggleFab extends ConsumerWidget {
  const ThemeModeToggleFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final isDark = mode == ThemeMode.dark;
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return FloatingActionButton.small(
      heroTag: 'theme-mode-toggle-fab',
      tooltip:
          isDark ? l10n.translate('themeToggleToLight') : l10n.translate('themeToggleToDark'),
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      onPressed: notifier.toggle,
      child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
    );
  }
}

class ThemeModeIconButton extends ConsumerWidget {
  const ThemeModeIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final isDark = mode == ThemeMode.dark;
    final l10n = context.l10n;

    return IconButton(
      tooltip:
          isDark ? l10n.translate('themeToggleToLight') : l10n.translate('themeToggleToDark'),
      onPressed: notifier.toggle,
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
    );
  }
}

