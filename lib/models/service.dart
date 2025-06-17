class VetService {
  final int? id;
  final String name;
  final String description;
  final double price;
  final int ownerId;
  final String? ownerName;
  final String? ownerLocation;
  final String? ownerPhone;
  final String? ownerCrmv;
  final String? operatingHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VetService({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.ownerId,
    this.ownerName,
    this.ownerLocation,
    this.ownerPhone,
    this.ownerCrmv,
    this.operatingHours,
    this.createdAt,
    this.updatedAt,
  });

  factory VetService.fromJson(Map<String, dynamic> json) {
    return VetService(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      ownerId: json['ownerId'] ?? 0,
      ownerName: json['ownerName'],
      ownerLocation: json['ownerLocation'],
      ownerPhone: json['ownerPhone'],
      ownerCrmv: json['ownerCrmv'],
      operatingHours: json['operatingHours'],
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
      'description': description,
      'price': price,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerLocation': ownerLocation,
      'ownerPhone': ownerPhone,
      'ownerCrmv': ownerCrmv,
      'operatingHours': operatingHours,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  VetService copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? ownerId,
    String? ownerName,
    String? ownerLocation,
    String? ownerPhone,
    String? ownerCrmv,
    String? operatingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VetService(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerLocation: ownerLocation ?? this.ownerLocation,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerCrmv: ownerCrmv ?? this.ownerCrmv,
      operatingHours: operatingHours ?? this.operatingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedPrice => 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
}