import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Stream<List<Vehicle>> getVehicles();
  Future<void> addVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String vehicleId);
}