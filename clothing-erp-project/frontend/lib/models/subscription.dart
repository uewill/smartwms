class Subscription {
  final String? id;
  final String? planType;
  final String? startDate;
  final String? endDate;
  final String? status;
  final int? maxShops;
  final List<String>? features;

  Subscription({
    this.id,
    this.planType,
    this.startDate,
    this.endDate,
    this.status,
    this.maxShops,
    this.features,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String?,
      planType: json['planType'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      status: json['status'] as String?,
      maxShops: json['maxShops'] as int?,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planType': planType,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'maxShops': maxShops,
      'features': features,
    };
  }

  Subscription copyWith({
    String? id,
    String? planType,
    String? startDate,
    String? endDate,
    String? status,
    int? maxShops,
    List<String>? features,
  }) {
    return Subscription(
      id: id ?? this.id,
      planType: planType ?? this.planType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      maxShops: maxShops ?? this.maxShops,
      features: features ?? this.features,
    );
  }
}
