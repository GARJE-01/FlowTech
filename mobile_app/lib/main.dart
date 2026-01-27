import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: FlowTechApp()));
}

class FlowTechApp extends ConsumerWidget {
  const FlowTechApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FlowTech Salesman',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
