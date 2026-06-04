import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/maintenance.dart';
import '../../domain/entities/category_maintenance.dart';
import '../../domain/repositories/maintenance_repository.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _maintenanceRef =>
      _firestore.collection('users').doc(_uid).collection('maintenances');

  CollectionReference get _categoriesRef =>
      _firestore.collection('users').doc(_uid).collection('categories');

  @override
  Stream<List<Maintenance>> getMaintenances(String vehicleId) {
    return _maintenanceRef
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Maintenance.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  @override
  Future<void> addMaintenance(Maintenance maintenance) async {
    await _maintenanceRef.add(maintenance.toMap());
  }

  @override
  Future<void> deleteMaintenance(String maintenanceId) async {
    await _maintenanceRef.doc(maintenanceId).delete();
  }

  @override
  Stream<List<CategoryMaintenance>> getCategories() {
    return _categoriesRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CategoryMaintenance.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList());
  }

  @override
  Future<void> addCategory(CategoryMaintenance category) async {
    await _categoriesRef.add(category.toMap());
  }
}