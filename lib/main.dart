import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ui/screens.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.purple,
      secondary: Colors.deepOrange,
      surface: Colors.white,
      surfaceTint: Colors.grey[200],
    );

    final themeData = ThemeData(
      fontFamily: 'Lato',
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shadowColor: colorScheme.shadow,
        elevation: 4,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
    );

    final router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/products',
  routes: [
    GoRoute(
      path: '/products',
      builder: (context, state) =>
          const ProductsOverviewScreen(),
    ),
    GoRoute(
      path: '/products/:productId',
      builder: (context, state) {
        final productId = state.pathParameters['productId']!;
        final product = ProductsManager().findById(
          productId,
        )!;
        return ProductDetailScreen(product);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersScreen(),
    ),
    GoRoute(
      path: '/my-products',
      builder: (context, state) =>
          const UserProductsScreen(),
    ),
  ],
);

return MaterialApp.router(
  title: 'My Shop',
  debugShowCheckedModeBanner: false,
      theme: themeData,
      routerConfig: router,
    );
  }
}
