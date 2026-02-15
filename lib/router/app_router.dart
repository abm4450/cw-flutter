import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/landing/landing_screen.dart';
import '../screens/customer/customer_portal_screen.dart';
import '../screens/admin/admin_portal_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthChangeNotifier(ref),
    redirect: (context, state) {
      final status = authState.status;
      final isLoginRoute = state.matchedLocation == '/';

      if (status == AuthStatus.loading) return null;

      if (status == AuthStatus.unauthenticated) {
        return isLoginRoute ? null : '/';
      }

      if (isLoginRoute) {
        return status == AuthStatus.admin ? '/admin' : '/customer';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const LandingScreen(),
      ),
      GoRoute(
        path: '/customer',
        builder: (_, _) => const CustomerPortalScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, _) => const AdminPortalScreen(),
      ),
    ],
  );
});

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _ref.listen(authProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
}
