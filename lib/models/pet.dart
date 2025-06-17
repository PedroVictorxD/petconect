class Pet {
  final int? id;
  final String name;
  final String type;
  final double weight;
  final int age;
  final String activityLevel;
  final String? breed;
  final String? notes;
  final int ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pet({
    this.id,
    required this.name,
    required this.type,
    required this.weight,
    required this.age,
    required this.activityLevel,
    this.breed,
    this.notes,
    required this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'] ?? '',
      type: json['type'] ?? 'CACHORRO',
      weight: (json['weight'] ?? 0).toDouble(),
      age: json['age'] ?? 0,
      activityLevel: json['activityLevel'] ?? 'MODERADA',
      breed: json['breed'],
      notes: json['notes'],
      ownerId: json['ownerId'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'weight': weight,
      'age': age,
      'activityLevel': activityLevel,
      'breed': breed,
      'notes': notes,
      'ownerId': ownerId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Pet copyWith({
    int? id,
    String? name,
    String? type,
    double? weight,
    int? age,
    String? activityLevel,
    String? breed,
    String? notes,
    int? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      breed: breed ?? this.breed,
      notes: notes ?? this.notes,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedWeight => '${weight.toStringAsFixed(1)} kg';
  
  String get ageDescription {
    if (age < 1) return 'Filhote';
    if (age == 1) return '1 ano';
    return '$age anos';
  }

  String get activityDescription {
    switch (activityLevel) {
      case 'BAIXA':
        return 'Baixa atividade';
      case 'MODERADA':
        return 'Atividade moderada';
      case 'ALTA':
        return 'Alta atividade';
      case 'MUITO_ALTA':
        return 'Muito ativa';
      default:
        return 'Atividade moderada';
    }
  }

  String get typeDescription {
    switch (type) {
      case 'CACHORRO':
        return 'Cachorro';
      case 'GATO':
        return 'Gato';
      case 'PASSARO':
        return 'Pássaro';
      case 'PEIXE':
        return 'Peixe';
      default:
        return 'Outro';
    }
  }
}

class FoodCalculation {
  final Pet pet;
  final Food food;
  final double dailyAmount;
  final int durationInDays;

  FoodCalculation({
    required this.pet,
    required this.food,
    required this.dailyAmount,
    required this.durationInDays,
  });

  double get totalAmount => dailyAmount * durationInDays;
  
  String get formattedDailyAmount => '${dailyAmount.toStringAsFixed(0)}g';
  String get formattedTotalAmount => '${totalAmount.toStringAsFixed(0)}g';
  
  int get totalAmountInKg => (totalAmount / 1000).ceil();
}

class Food {
  final int? id;
  final String brand;
  final String name;
  final String type; // Filhote, Adulto, Senior
  final double recommendedDailyAmount; // g por kg de peso
  final String? notes;
  final int ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Food({
    this.id,
    required this.brand,
    required this.name,
    required this.type,
    required this.recommendedDailyAmount,
    this.notes,
    required this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      brand: json['brand'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'Adulto',
      recommendedDailyAmount: (json['recommendedDailyAmount'] ?? 0).toDouble(),
      notes: json['notes'],
      ownerId: json['ownerId'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'name': name,
      'type': type,
      'recommendedDailyAmount': recommendedDailyAmount,
      'notes': notes,
      'ownerId': ownerId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Food copyWith({
    int? id,
    String? brand,
    String? name,
    String? type,
    double? recommendedDailyAmount,
    String? notes,
    int? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Food(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      type: type ?? this.type,
      recommendedDailyAmount: recommendedDailyAmount ?? this.recommendedDailyAmount,
      notes: notes ?? this.notes,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => '$brand - $name ($type)';
}