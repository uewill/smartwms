class PurchaseOrderItem {
  final String? skuId;
  final String? styleNo;
  final String? productName;
  final String? colorName;
  final String? sizeName;
  final double? price;
  final int? quantity;
  final double? subtotal;

  PurchaseOrderItem({
    this.skuId,
    this.styleNo,
    this.productName,
    this.colorName,
    this.sizeName,
    this.price,
    this.quantity,
    this.subtotal,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      skuId: json['skuId'] as String?,
      styleNo: json['styleNo'] as String?,
      productName: json['productName'] as String?,
      colorName: json['colorName'] as String?,
      sizeName: json['sizeName'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      quantity: json['quantity'] as int?,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skuId': skuId,
      'styleNo': styleNo,
      'productName': productName,
      'colorName': colorName,
      'sizeName': sizeName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

class PurchaseOrder {
  final String? id;
  final String? orderNo;
  final String? supplierName;
  final double? totalAmount;
  final List<PurchaseOrderItem>? items;
  final String? createdAt;

  PurchaseOrder({
    this.id,
    this.orderNo,
    this.supplierName,
    this.totalAmount,
    this.items,
    this.createdAt,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'] as String?,
      orderNo: json['orderNo'] as String?,
      supplierName: json['supplierName'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => PurchaseOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'supplierName': supplierName,
      'totalAmount': totalAmount,
      'items': items?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
    };
  }
}
