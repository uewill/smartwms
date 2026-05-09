import 'package:smartwms/models/product.dart';

class InboundOrder {
  final String id;
  final String orderNo;
  final String warehouseId;
  final String warehouseName;
  final String supplier;
  final int totalQuantity;
  final double totalAmount;
  final String status;
  final String? remark;
  final String? operatorId;
  final String operatorName;
  final DateTime createdAt;
  final List<InboundOrderItem> items;

  InboundOrder({
    required this.id,
    required this.orderNo,
    required this.warehouseId,
    required this.warehouseName,
    this.supplier = '',
    this.totalQuantity = 0,
    this.totalAmount = 0.0,
    this.status = 'pending',
    this.remark,
    this.operatorId,
    this.operatorName = '',
    DateTime? createdAt,
    this.items = const [],
  }): createdAt = createdAt ?? DateTime.now();

  factory InboundOrder.fromJson(Map<String, dynamic> json) {
    return InboundOrder(
      id: json['id']?.toString() ?? '',
      orderNo: json['orderNo'] ?? '',
      warehouseId: json['warehouseId']?.toString() ?? '',
      warehouseName: json['warehouseName'] ?? '',
      supplier: json['supplier'] ?? '',
      totalQuantity: json['totalQuantity'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      remark: json['remark'],
      operatorId: json['operatorId']?.toString(),
      operatorName: json['operatorName'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      items: json['items'] != null
          ? (json['items'] as List).map((e) => InboundOrderItem.fromJson(e)).toList()
          : [],
    );
  }
}

class InboundOrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productCode;
  final int quantity;
  final double price;

  InboundOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productCode,
    this.quantity = 0,
    this.price = 0.0,
  });

  factory InboundOrderItem.fromJson(Map<String, dynamic> json) {
    return InboundOrderItem(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'] ?? '',
      productCode: json['productCode'],
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  double get amount => price * quantity;
}

class OutboundOrder {
  final String id;
  final String orderNo;
  final String warehouseId;
  final String warehouseName;
  final String customer;
  final int totalQuantity;
  final double totalAmount;
  final String status;
  final String? remark;
  final String? operatorId;
  final String operatorName;
  final DateTime createdAt;
  final List<OutboundOrderItem> items;

  OutboundOrder({
    required this.id,
    required this.orderNo,
    required this.warehouseId,
    required this.warehouseName,
    this.customer = '',
    this.totalQuantity = 0,
    this.totalAmount = 0.0,
    this.status = 'pending',
    this.remark,
    this.operatorId,
    this.operatorName = '',
    DateTime? createdAt,
    this.items = const [],
  }): createdAt = createdAt ?? DateTime.now();

  factory OutboundOrder.fromJson(Map<String, dynamic> json) {
    return OutboundOrder(
      id: json['id']?.toString() ?? '',
      orderNo: json['orderNo'] ?? '',
      warehouseId: json['warehouseId']?.toString() ?? '',
      warehouseName: json['warehouseName'] ?? '',
      customer: json['customer'] ?? '',
      totalQuantity: json['totalQuantity'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      remark: json['remark'],
      operatorId: json['operatorId']?.toString(),
      operatorName: json['operatorName'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      items: json['items'] != null
          ? (json['items'] as List).map((e) => OutboundOrderItem.fromJson(e)).toList()
          : [],
    );
  }
}

class OutboundOrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productCode;
  final int quantity;
  final double costPrice;

  OutboundOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productCode,
    this.quantity = 0,
    this.costPrice = 0.0,
  });

  factory OutboundOrderItem.fromJson(Map<String, dynamic> json) {
    return OutboundOrderItem(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'] ?? '',
      productCode: json['productCode'],
      quantity: json['quantity'] ?? 0,
      costPrice: (json['costPrice'] ?? 0).toDouble(),
    );
  }
}

class InventoryItem {
  final String productId;
  final String productName;
  final String warehouseId;
  final String warehouseName;
  final int quantity;

  InventoryItem({
    required this.productId,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantity,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'] ?? '',
      warehouseId: json['warehouseId']?.toString() ?? '',
      warehouseName: json['warehouseName'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }
}

class WarehouseStat {
  final String warehouseId;
  final String warehouseName;
  final int quantity;

  WarehouseStat({
    required this.warehouseId,
    required this.warehouseName,
    required this.quantity,
  });

  factory WarehouseStat.fromJson(Map<String, dynamic> json) {
    return WarehouseStat(
      warehouseId: json['warehouseId']?.toString() ?? '',
      warehouseName: json['warehouseName'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }
}

class InventoryReport {
  final int totalProductTypes;
  final int totalQuantity;
  final List<WarehouseStat> warehouseStats;
  final List<Product> lowStockProducts;
  final List<InventoryItem> productInventory;

  InventoryReport({
    required this.totalProductTypes,
    required this.totalQuantity,
    required this.warehouseStats,
    required this.lowStockProducts,
    required this.productInventory,
  });

  factory InventoryReport.fromJson(Map<String, dynamic> json) {
    return InventoryReport(
      totalProductTypes: json['totalProductTypes'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
      warehouseStats: json['warehouseStats'] != null
          ? (json['warehouseStats'] as List).map((e) => WarehouseStat.fromJson(e)).toList()
          : [],
      lowStockProducts: json['lowStockProducts'] != null
          ? (json['lowStockProducts'] as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList()
          : [],
      productInventory: json['productInventory'] != null
          ? (json['productInventory'] as List).map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class CostTrend {
  final String month;
  final double inboundCost;
  final double outboundCost;

  CostTrend({
    required this.month,
    required this.inboundCost,
    required this.outboundCost,
  });

  factory CostTrend.fromJson(Map<String, dynamic> json) {
    return CostTrend(
      month: json['month'] ?? '',
      inboundCost: (json['inboundCost'] ?? 0).toDouble(),
      outboundCost: (json['outboundCost'] ?? 0).toDouble(),
    );
  }
}

class CostReport {
  final double monthInboundCost;
  final double monthOutboundCost;
  final double totalInventoryValue;
  final double averageCost;
  final List<CostTrend> monthlyTrend;

  CostReport({
    required this.monthInboundCost,
    required this.monthOutboundCost,
    required this.totalInventoryValue,
    required this.averageCost,
    required this.monthlyTrend,
  });

  factory CostReport.fromJson(Map<String, dynamic> json) {
    return CostReport(
      monthInboundCost: (json['monthInboundCost'] ?? 0).toDouble(),
      monthOutboundCost: (json['monthOutboundCost'] ?? 0).toDouble(),
      totalInventoryValue: (json['totalInventoryValue'] ?? 0).toDouble(),
      averageCost: (json['averageCost'] ?? 0).toDouble(),
      monthlyTrend: json['monthlyTrend'] != null
          ? (json['monthlyTrend'] as List).map((e) => CostTrend.fromJson(e)).toList()
          : [],
    );
  }
}
