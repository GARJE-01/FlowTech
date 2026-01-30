import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/city/presentation/city_selection_screen.dart';
import '../../features/city/data/city_service.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/scaffold_with_navbar.dart'; // New Import

import '../../features/shop/presentation/shop_list_screen.dart'; // New Import
import '../../features/shop/presentation/add_shop_screen.dart'; // New Import
import '../../features/shop/presentation/shop_detail_screen.dart'; // New Import

import '../../features/product/presentation/product_catalog_screen.dart'; // New Import
import '../../features/order/presentation/cart_review_screen.dart'; // New Import
import '../../features/order/presentation/order_tracking_placeholder_screen.dart'; // New Import
import '../../features/order/presentation/order_shop_selection_screen.dart'; // New Import
import '../../features/order_tracking/presentation/order_list_screen.dart'; // New Import
import '../../features/order_tracking/presentation/order_detail_screen.dart'; // New Import
import '../../features/invoice/presentation/invoice_screen.dart'; // New Import
import '../../features/payment/presentation/payment_list_screen.dart'; // New Import
import '../../features/payment/presentation/payment_detail_screen.dart';
import '../../features/notification/presentation/notification_list_screen.dart'; // New Import
import '../../features/notification/presentation/notification_detail_screen.dart'; // New Import
import '../../features/reports/presentation/reports_home_screen.dart';
import '../../features/reports/presentation/daily_summary_screen.dart';
import '../../features/reports/presentation/period_summary_screen.dart';
import '../../features/reports/presentation/shop_report_screen.dart';
import '../../features/reports/presentation/product_report_screen.dart';
import '../../features/reports/presentation/performance_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final cityState = ref.watch(cityProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: ListenableMerge([
       ValueNotifier(authState),
       ValueNotifier(cityState),
    ]), 
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final hasCitySelected = cityState.hasCitySelected;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSelectingCity = state.uri.toString() == '/city-selection';

      // 1. Not Logged In -> Force Login
      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      // 2. Logged In, No City -> Force City Selection
      if (isLoggedIn && !hasCitySelected) {
        return isSelectingCity ? null : '/city-selection';
      }

      // 3. Logged In, City Selected -> Redirect away from Login (but allow explicit City Select)
      if (isLoggedIn && hasCitySelected && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/city-selection',
        builder: (context, state) => const CitySelectionScreen(),
      ),
      
      // Feature 5: Product Catalog (Create Order Flow) & Cart
      GoRoute(
        path: '/products',
        parentNavigatorKey: _rootNavigatorKey, // Full screen for order creation process
        builder: (context, state) => const ProductCatalogScreen(),
      ),
      GoRoute(
        path: '/cart',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CartReviewScreen(),
      ),
      GoRoute(
        path: '/order/select-shop',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OrderShopSelectionScreen(),
      ),

      // Shell Route for Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
           GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          
          // --- Feature 4: Shop Management ---
          GoRoute(
            path: '/shops',
            builder: (context, state) => const ShopListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => ShopDetailScreen(shopId: state.pathParameters['id']!),
              ),
            ],
          ),
          
          // ... (Orders, Bills, etc.) ...
          // --- Feature Other: Orders ---
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrderListScreen(),
          ),



// ...



           // --- Feature Other: Bills ---
          GoRoute(
            path: '/bills',
             // For now, link generic bills to "Orders" or specific invoice list if we had one.
             // But requirement says "Invoice accessible from Dashboard".
             // Let's redirect /bills to /orders for now as it's the gateway.
             redirect: (context, state) => '/orders', 
          ),
          
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentListScreen(),

          ),
          

          
                    // --- Feature Profile ---
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          

        ],
      ),
      
      // --- Full Screen Routes (Outside Shell) ---
      GoRoute(
        path: '/add-shop',
        parentNavigatorKey: _rootNavigatorKey, 
        builder: (context, state) => const AddShopScreen(),
      ),
      GoRoute(
         path: '/orders/:id',
         parentNavigatorKey: _rootNavigatorKey,
         builder: (context, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/orders/create',
         parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(title: 'Create New Order'),
      ),
      GoRoute(
        path: '/invoices/:orderId',
         parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => InvoiceScreen(orderId: state.pathParameters['orderId']!),
      ),

      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationListScreen(),
      ),

      GoRoute(
        path: '/payment-details/:id',
        builder: (context, state) => PaymentDetailScreen(paymentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/notifications/:id',
        builder: (context, state) => NotificationDetailScreen(notificationId: state.pathParameters['id']!),
      ),

      GoRoute(
         path: '/reports',
         parentNavigatorKey: _rootNavigatorKey,
         builder: (context, state) => const ReportsHomeScreen(),
         routes: [
           GoRoute(
             path: 'daily',
             builder: (context, state) => const DailySummaryScreen(),
           ),
           GoRoute(
             path: 'period/:type',
             builder: (context, state) => PeriodSummaryScreen(periodType: state.pathParameters['type']!),
           ),
           GoRoute(
             path: 'shops',
             builder: (context, state) => const ShopReportScreen(),
           ),
           GoRoute(
             path: 'products',
             builder: (context, state) => const ProductReportScreen(),
           ),
           GoRoute(
             path: 'performance',
             builder: (context, state) => const PerformanceScreen(),
           ),
         ]
      ),
    ],
  );
});

// Helper for merging Listenables
class ListenableMerge extends Listenable {
  final List<Listenable> _listenables;
  ListenableMerge(this._listenables);
  
  @override
  void addListener(VoidCallback listener) {
    for (final l in _listenables) {
      l.addListener(listener);
    }
  }
  
  @override
  void removeListener(VoidCallback listener) {
    for (final l in _listenables) {
      l.removeListener(listener);
    }
  }
}

