class Maintenance {
  final String id;
  final String vehicleId;
  final DateTime date;
  final String description;
  final double amount;
  final String categoryId;

  Maintenance({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.description,
    required this.amount,
    required this.categoryId,
  });

  factory Maintenance.fromMap(Map<String, dynamic> map, String id) {
    return Maintenance(
      id: id,
      vehicleId: map['vehicleId'] ?? '',
      date: (map['date'] as dynamic).toDate(),
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      categoryId: map['categoryId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'date': date,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
    };
  }
}