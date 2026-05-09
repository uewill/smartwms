class Product {
  final String id;
  final int tenantId;
  final String code;
  final String name;
  final String spec;
  final String unit;
  final double price;
  final double costPrice;
  final int warningStock;
  final int stockQuantity;
  final String category;
  final String? remark;
  final String? image;
  final String status;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    this.spec = '',
    this.unit = '个',
    this.price = 0.0,
    this.costPrice = 0.0,
    this.warningStock = 0,
    this.stockQuantity = 0,
    this.category = '',
    this.remark,
    this.image,
    this.status = 'active',
    DateTime? createdAt,
  }): createdAt = createdAt ?? DateTime.now();

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId'] ?? 0,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      spec: json['spec'] ?? '',
      unit: json['unit'] ?? '个',
      price: (json['price'] ?? 0).toDouble(),
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      warningStock: json['warningStock'] ?? 0,
      stockQuantity: json['stockQuantity'] ?? 0,
      category: json['category'] ?? '',
      remark: json['remark'],
      image: json['image'],
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'spec': spec,
    'unit': unit,
    'price': price,
    'costPrice': costPrice,
    'warningStock': warningStock,
    'category': category,
    'remark': remark,
  };
}

class Warehouse {
  final String id;
  final int tenantId;
  final String name;
  final String address;
  final String contact;
  final String phone;
  final int productCount;
  final int totalStock;
  final String status;
  final DateTime createdAt;

  Warehouse({
    required this.id,
    required this.tenantId,
    required this.name,
    this.address = '',
    this.contact = '',
    this.phone = '',
    this.productCount = 0,
    this.totalStock = 0,
    this.status = 'active',
    DateTime? createdAt,
  }): createdAt = createdAt ?? DateTime.now();

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenantId'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      contact: json['contact'] ?? '',
      phone: json['phone'] ?? '',
      productCount: json['productCount'] ?? 0,
      totalStock: json['totalStock'] ?? 0,
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'contact': contact,
    'phone': phone,
  };
}
