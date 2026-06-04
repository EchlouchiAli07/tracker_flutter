class FuelEntry {
  final String id;
  final String vehicleId;
  final DateTime date;
  final double liters;
  final double amount;
  final double mileage;

  FuelEntry({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.liters,
    required this.amount,
    required this.mileage,
  });

  factory FuelEntry.fromMap(Map<String, dynamic> map, String id) {
    return FuelEntry(
      id: id,
      vehicleId: map['vehicleId'] ?? '',
      date: (map['date'] as dynamic).toDate(),
      liters: (map['liters'] ?? 0).toDouble(),
      amount: (map['amount'] ?? 0).toDouble(),
      mileage: (map['mileage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'date': date,
      'liters': liters,
      'amount': amount,
      'mileage': mileage,
    };
  }
}