class User {
  final int? id;
  final String name;
  final String email;
  final String userType;
  final String? cnpj;
  final String? crmv;
  final String location;
  final String phone;
  final String? responsibleName;
  final String? storeType;
  final String? operatingHours;
  final List<SecurityQuestion>? securityQuestions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.cnpj,
    this.crmv,
    required this.location,
    required this.phone,
    this.responsibleName,
    this.storeType,
    this.operatingHours,
    this.securityQuestions,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      userType: json['userType'] ?? '',
      cnpj: json['cnpj'],
      crmv: json['crmv'],
      location: json['location'] ?? '',
      phone: json['phone'] ?? '',
      responsibleName: json['responsibleName'],
      storeType: json['storeType'],
      operatingHours: json['operatingHours'],
      securityQuestions: json['securityQuestions'] != null
          ? (json['securityQuestions'] as List)
              .map((q) => SecurityQuestion.fromJson(q))
              .toList()
          : null,
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
      'email': email,
      'userType': userType,
      'cnpj': cnpj,
      'crmv': crmv,
      'location': location,
      'phone': phone,
      'responsibleName': responsibleName,
      'storeType': storeType,
      'operatingHours': operatingHours,
      'securityQuestions': securityQuestions?.map((q) => q.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? userType,
    String? cnpj,
    String? crmv,
    String? location,
    String? phone,
    String? responsibleName,
    String? storeType,
    String? operatingHours,
    List<SecurityQuestion>? securityQuestions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      cnpj: cnpj ?? this.cnpj,
      crmv: crmv ?? this.crmv,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      responsibleName: responsibleName ?? this.responsibleName,
      storeType: storeType ?? this.storeType,
      operatingHours: operatingHours ?? this.operatingHours,
      securityQuestions: securityQuestions ?? this.securityQuestions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLojista => userType == 'LOJISTA';
  bool get isTutor => userType == 'TUTOR';
  bool get isVeterinario => userType == 'VETERINARIO';
  bool get isAdmin => userType == 'ADMINISTRADOR';
}

class SecurityQuestion {
  final int? id;
  final String question;
  final String answer;

  SecurityQuestion({
    this.id,
    required this.question,
    required this.answer,
  });

  factory SecurityQuestion.fromJson(Map<String, dynamic> json) {
    return SecurityQuestion(
      id: json['id'],
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }
}