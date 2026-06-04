import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/repositories/auth_repository_impl.dart';
import '../domain/repositories/vehicle_repository_impl.dart';
import '../domain/repositories/fuel_repository_impl.dart';
import '../domain/repositories/maintenance_repository_impl.dart';
import '../domain/entities/vehicle.dart';
import '../domain/entities/fuel_entry.dart';
import '../domain/entities/maintenance.dart';
import '../domain/entities/category_maintenance.dart';

// Repositories
final authRepositoryProvider = Provider((ref) => AuthRepositoryImpl());
final vehicleRepositoryProvider = Provider((ref) => VehicleRepositoryImpl());
final fuelRepositoryProvider = Provider((ref) => FuelRepositoryImpl());
final maintenanceRepositoryProvider = Provider((ref) => MaintenanceRepositoryImpl());

// HTTP client
final dioProvider = Provider((ref) => Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    )));

// Auth
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Vehicles
final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) {
  return ref.watch(vehicleRepositoryProvider).getVehicles();
});

// Fuel
final fuelEntriesProvider = StreamProvider.family<List<FuelEntry>, String>((ref, vehicleId) {
  return ref.watch(fuelRepositoryProvider).getFuelEntries(vehicleId);
});

// Maintenance
final maintenancesProvider = StreamProvider.family<List<Maintenance>, String>((ref, vehicleId) {
  return ref.watch(maintenanceRepositoryProvider).getMaintenances(vehicleId);
});

// Categories
final categoriesProvider = StreamProvider<List<CategoryMaintenance>>((ref) {
  return ref.watch(maintenanceRepositoryProvider).getCategories();
});

// Dashboard stats
final dashboardStatsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final vehiclesStream = ref.watch(vehicleRepositoryProvider).getVehicles();
  final now = DateTime.now();

  bool isCurrentMonth(DateTime date) {
    return date.year == now.year && date.month == now.month;
  }

  return vehiclesStream.asyncMap((vehicles) async {
    double totalFuel = 0;
    double totalMaintenance = 0;
    double monthFuel = 0;
    double monthMaintenance = 0;
    final fuelByVehicle = <Map<String, dynamic>>[];

    for (final v in vehicles) {
      final fuels = await ref.read(fuelRepositoryProvider).getFuelEntries(v.id).first;
      final maintenances = await ref.read(maintenanceRepositoryProvider).getMaintenances(v.id).first;

      totalFuel += fuels.fold(0.0, (sum, e) => sum + e.amount);
      totalMaintenance += maintenances.fold(0.0, (sum, e) => sum + e.amount);

      final currentMonthFuels = fuels.where((f) => isCurrentMonth(f.date));
      final monthLiters = currentMonthFuels.fold(0.0, (sum, e) => sum + e.liters);
      final monthAmount = currentMonthFuels.fold(0.0, (sum, e) => sum + e.amount);
      monthFuel += monthAmount;
      monthMaintenance += maintenances.where((m) => isCurrentMonth(m.date)).fold(0.0, (sum, e) => sum + e.amount);

      fuelByVehicle.add({
        'vehicle': v,
        'liters': monthLiters,
        'amount': monthAmount,
      });
    }

    final total = totalFuel + totalMaintenance;
    final totalMonth = monthFuel + monthMaintenance;

    return {
      'vehicles': vehicles,
      'totalFuel': totalFuel,
      'totalMaintenance': totalMaintenance,
      'total': total,
      'fuelPct': total > 0 ? (totalFuel / total * 100) : 0.0,
      'maintPct': total > 0 ? (totalMaintenance / total * 100) : 0.0,
      'monthFuel': monthFuel,
      'monthMaintenance': monthMaintenance,
      'monthTotal': totalMonth,
      'monthFuelPct': totalMonth > 0 ? (monthFuel / totalMonth * 100) : 0.0,
      'monthMaintPct': totalMonth > 0 ? (monthMaintenance / totalMonth * 100) : 0.0,
      'fuelByVehicle': fuelByVehicle,
    };
  });
});