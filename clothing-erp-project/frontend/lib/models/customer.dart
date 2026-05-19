class Customer {
  final String? id;
  final String? name;
  final String? phone;
  final String? remark;
  final double? totalDebt;
  final String? lastPurchaseAt;

  Customer({
    this.id,
    this.name,
    this.phone,
    this.remark,
    this.totalDebt,
    this.lastPurchaseAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      remark: json['remark'] as String?,
      totalDebt: (json['totalDebt'] as num?)?.toDouble(),
      lastPurchaseAt: json['lastPurchaseAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'remark': remark,
      'totalDebt': totalDebt,
      'lastPurchaseAt': lastPurchaseAt,
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? remark,
    double? totalDebt,
    String? lastPurchaseAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      remark: remark ?? this.remark,
      totalDebt: totalDebt ?? this.totalDebt,
      lastPurchaseAt: lastPurchaseAt ?? this.lastPurchaseAt,
    );
  }
}
