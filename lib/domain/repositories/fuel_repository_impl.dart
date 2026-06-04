import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/fuel_entry.dart';
import '../../domain/repositories/fuel_repository.dart';

class FuelRepositoryImpl implements FuelRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _fuelRef =>
      _firestore.collection('users').doc(_uid).collection('fuel_entries');

  @override
  Stream<List<FuelEntry>> getFuelEntries(String vehicleId) {
    return _fuelRef
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FuelEntry.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    });
  }

  @override
  Future<void> addFuelEntry(FuelEntry fuelEntry) async {
    await _fuelRef.add(fuelEntry.toMap());
  }

  @override
  Future<void> deleteFuelEntry(String fuelEntryId) async {
    await _fuelRef.doc(fuelEntryId).delete();
  }
}