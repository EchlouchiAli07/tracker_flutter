import '../entities/fuel_entry.dart';

abstract class FuelRepository {
  Stream<List<FuelEntry>> getFuelEntries(String vehicleId);
  Future<void> addFuelEntry(FuelEntry fuelEntry);
  Future<void> deleteFuelEntry(String fuelEntryId);
}