class Shop {
  final String? id;
  final String? name;
  final String? role;
  final String? inviteCode;
  final String? address;

  Shop({
    this.id,
    this.name,
    this.role,
    this.inviteCode,
    this.address,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
      inviteCode: json['inviteCode'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'inviteCode': inviteCode,
      'address': address,
    };
  }

  Shop copyWith({
    String? id,
    String? name,
    String? role,
    String? inviteCode,
    String? address,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      inviteCode: inviteCode ?? this.inviteCode,
      address: address ?? this.address,
    );
  }
}
