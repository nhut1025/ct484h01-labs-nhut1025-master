import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

    // (1) Create an AuthManager object
    final authManager = AuthManager();

    final router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/auto-login', // (2) Auto login on app start
      refreshListenable: authManager, // (3) Listen to auth state changes
      redirect: (context, state) {
        // (4) Configure redirection based on auth state
        final authManager = context.read<AuthManager>();
        final isAtAuthScreen = state.fullPath == '/auth';

        // If not authenticated and not at auth screen, redirect to auth screen
        if (!authManager.isAuth && !isAtAuthScreen) {
          return '/auth';
        }

        // If authenticated and at auth screen, redirect to products screen
        if (authManager.isAuth && isAtAuthScreen) {
          return '/products';
        }

        // In other cases, allow access
        return null;
      },
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => const SafeArea(child: AuthScreen()),
        ),
        GoRoute(
          path: '/auto-login',
          builder: (context, state) {
            return FutureBuilder(
              future: context.read<AuthManager>().tryAutoLogin(),
              builder: (context, authSnapshot) =>
                  const SafeArea(child: SplashScreen()),
            );
          },
        ),
        GoRoute(
          path: '/logout',
          builder: (context, state) => FutureBuilder(
            future: context.read<AuthManager>().logout(),
            builder: (context, authSnapshot) =>
                const SafeArea(child: SplashScreen()),
          ),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsOverviewScreen(),
        ),
        GoRoute(
          path: '/products/:productId',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            final product = context.read<ProductsManager>().findById(
              productId,
            )!;
            return SafeArea(child: ProductDetailScreen(product));
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
          builder: (context, state) => const UserProductsScreen(),
        ),
        GoRoute(
          path: '/my-products/new',
          builder: (context, state) => SafeArea(child: EditProductScreen(null)),
        ),
        GoRoute(
          path: '/my-products/:productId/edit',
          builder: (context, state) {
            final productId = state.pathParameters['productId'];
            final product = productId != null
                ? context.read<ProductsManager>().findById(productId)
                : null;
            return SafeArea(child: EditProductScreen(product));
          },
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: authManager,
        ), // (5) Provide auth manager
        ChangeNotifierProvider(create: (context) => ProductsManager()),
        ChangeNotifierProvider(create: (context) => OrdersManager()),
        ChangeNotifierProvider(create: (context) => CartManager()),
      ],
      child: MaterialApp.router(
        title: 'My Shop',
        debugShowCheckedModeBanner: false,
        theme: themeData,
        routerConfig: router,
      ),
    );
  }
}
