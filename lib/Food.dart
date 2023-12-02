class Food {
  final int id;
  final String name;
  final double calories;
  // final DateTime date;

  Food({required this.id, required this.name, required this.calories});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      // 'date': date.toIso8601String(),
    };
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      // date: DateTime.parse(map['date']),
    );
  }
}
