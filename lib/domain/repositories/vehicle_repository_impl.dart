import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _vehiclesRef =>
      _firestore.collection('users').doc(_uid).collection('vehicles');

  @override
  Stream<List<Vehicle>> getVehicles() {
    return _vehiclesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Vehicle.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    });
  }

  @override
  Future<void> addVehicle(Vehicle vehicle) async {
    await _vehiclesRef.add(vehicle.toMap());
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    await _vehiclesRef.doc(vehicleId).delete();
  }
}