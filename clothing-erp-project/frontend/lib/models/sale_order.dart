class SaleOrderItem {
  final String? skuId;
  final String? styleNo;
  final String? productName;
  final String? colorName;
  final String? sizeName;
  final double? price;
  final int? quantity;
  final double? subtotal;

  SaleOrderItem({
    this.skuId,
    this.styleNo,
    this.productName,
    this.colorName,
    this.sizeName,
    this.price,
    this.quantity,
    this.subtotal,
  });

  factory SaleOrderItem.fromJson(Map<String, dynamic> json) {
    return SaleOrderItem(
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

class SaleOrder {
  final String? id;
  final String? orderNo;
  final String? customerName;
  final double? totalAmount;
  final double? actualAmount;
  final String? paymentMethod;
  final List<SaleOrderItem>? items;
  final String? createdAt;

  SaleOrder({
    this.id,
    this.orderNo,
    this.customerName,
    this.totalAmount,
    this.actualAmount,
    this.paymentMethod,
    this.items,
    this.createdAt,
  });

  factory SaleOrder.fromJson(Map<String, dynamic> json) {
    return SaleOrder(
      id: json['id'] as String?,
      orderNo: json['orderNo'] as String?,
      customerName: json['customerName'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      actualAmount: (json['actualAmount'] as num?)?.toDouble(),
      paymentMethod: json['paymentMethod'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => SaleOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'customerName': customerName,
      'totalAmount': totalAmount,
      'actualAmount': actualAmount,
      'paymentMethod': paymentMethod,
      'items': items?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
    };
  }
}
