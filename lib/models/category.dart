class Category {
  final String id;
  final String name;
  final int colorValue; // Color.value for display
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    this.colorValue = 0xFF6366F1, // indigo default
    required this.createdAt,
  });

  Category copyWith({String? name, int? colorValue}) {
    return Category(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Category.fromMap(Map<dynamic, dynamic> map) => Category(
        id: map['id'] as String,
        name: map['name'] as String,
        colorValue: map['colorValue'] as int? ?? 0xFF6366F1,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
