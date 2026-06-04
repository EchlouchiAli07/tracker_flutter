import '../entities/maintenance.dart';
import '../entities/category_maintenance.dart';

abstract class MaintenanceRepository {
  Stream<List<Maintenance>> getMaintenances(String vehicleId);
  Future<void> addMaintenance(Maintenance maintenance);
  Future<void> deleteMaintenance(String maintenanceId);
  Stream<List<CategoryMaintenance>> getCategories();
  Future<void> addCategory(CategoryMaintenance category);
}