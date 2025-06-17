class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String measurementUnit;
  final int ownerId;
  final String? ownerName;
  final String? ownerLocation;
  final String? ownerPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.measurementUnit,
    required this.ownerId,
    this.ownerName,
    this.ownerLocation,
    this.ownerPhone,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      measurementUnit: json['measurementUnit'] ?? 'UNIDADE',
      ownerId: json['ownerId'] ?? 0,
      ownerName: json['ownerName'],
      ownerLocation: json['ownerLocation'],
      ownerPhone: json['ownerPhone'],
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
      'imageUrl': imageUrl,
      'measurementUnit': measurementUnit,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerLocation': ownerLocation,
      'ownerPhone': ownerPhone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? measurementUnit,
    int? ownerId,
    String? ownerName,
    String? ownerLocation,
    String? ownerPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerLocation: ownerLocation ?? this.ownerLocation,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedPrice => 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
}