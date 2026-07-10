import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/settings_repository.dart' show AppThemeMode;
import 'providers/settings_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: NumberMergeApp()));
}

class NumberMergeApp extends ConsumerWidget {
  const NumberMergeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));

    return MaterialApp.router(
      title: 'Number Merge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _toFlutterThemeMode(themeMode),
      routerConfig: appRouter,
    );
  }

  ThemeMode _toFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
