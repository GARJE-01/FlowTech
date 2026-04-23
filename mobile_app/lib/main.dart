import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/storage/storage_service.dart';
import 'src/features/shop/data/shop_service.dart';
import 'src/features/order/data/order_service.dart';
import 'src/features/payment/data/payment_service.dart';
import 'src/features/product/data/product_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.init();

  runApp(ProviderScope(
    overrides: [
      storageServiceProvider.overrideWith((ref) => storageService),
      shopProvider.overrideWith((ref) => ShopService(storageService, ref)),
      orderListProvider.overrideWith((ref) => OrderListNotifier(ref, storageService)),

      paymentProvider.overrideWith((ref) => PaymentNotifier(ref, storageService)),
      productProvider.overrideWith((ref) => ProductService(storageService)),
    ],

    child: const FlowTechApp(),
  ));
}

class FlowTechApp extends ConsumerWidget {
  const FlowTechApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FlowTech',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
