import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../presentation/auth/login_page.dart';
import '../../presentation/auth/register_page.dart';
import '../../presentation/dashboard/dashboard_page.dart';
import '../../presentation/vehicles/vehicles_list_page.dart';
import '../../presentation/vehicles/add_vehicle_page.dart';
import '../../presentation/fuel/add_fuel_page.dart';
import '../../presentation/maintenance/add_maintenance_page.dart';
import '../../presentation/maintenance/maintenance_history_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (user == null && !isAuthRoute) return '/login';
      if (user != null && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterPage()),
      GoRoute(path: '/', builder: (c, s) => const DashboardPage()),
      GoRoute(path: '/vehicles', builder: (c, s) => const VehiclesListPage()),
      GoRoute(path: '/vehicles/add', builder: (c, s) => const AddVehiclePage()),
      GoRoute(
        path: '/fuel/add',
        builder: (c, s) => AddFuelPage(vehicleId: s.extra as String?),
      ),
      GoRoute(
        path: '/maintenance/add',
        builder: (c, s) => AddMaintenancePage(vehicleId: s.extra as String?),
      ),
      GoRoute(
        path: '/maintenance/history',
        builder: (c, s) => MaintenanceHistoryPage(vehicleId: s.extra as String?),
      ),
    ],
  );
});