class CategoryMaintenance {
  final String id;
  final String label;

  CategoryMaintenance({
    required this.id,
    required this.label,
  });

  factory CategoryMaintenance.fromMap(Map<String, dynamic> map, String id) {
    return CategoryMaintenance(
      id: id,
      label: map['label'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
    };
  }
}