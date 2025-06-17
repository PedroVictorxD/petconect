class Store {
  final int? id;
  final String name;
  final String cnpj;
  final String email;
  final String location;
  final String phone;
  final String storeType; // VIRTUAL ou FISICA
  final int ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Store({
    this.id,
    required this.name,
    required this.cnpj,
    required this.email,
    required this.location,
    required this.phone,
    required this.storeType,
    required this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'] ?? '',
      cnpj: json['cnpj'] ?? '',
      email: json['email'] ?? '',
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      storeType: json['storeType'] ?? 'FISICA',
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
      'cnpj': cnpj,
      'email': email,
      'location': location,
      'phone': phone,
      'storeType': storeType,
      'ownerId': ownerId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Store copyWith({
    int? id,
    String? name,
    String? cnpj,
    String? email,
    String? location,
    String? phone,
    String? storeType,
    int? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      cnpj: cnpj ?? this.cnpj,
      email: email ?? this.email,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      storeType: storeType ?? this.storeType,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedCnpj {
    if (cnpj.length == 14) {
      return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12, 14)}';
    }
    return cnpj;
  }

  String get formattedPhone {
    if (phone.length == 11) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 7)}-${phone.substring(7, 11)}';
    } else if (phone.length == 10) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6, 10)}';
    }
    return phone;
  }

  String get storeTypeDescription {
    return storeType == 'VIRTUAL' ? 'Loja Virtual' : 'Loja Física';
  }

  bool get isVirtual => storeType == 'VIRTUAL';
  bool get isPhysical => storeType == 'FISICA';
}