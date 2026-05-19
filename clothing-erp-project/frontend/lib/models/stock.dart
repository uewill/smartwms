class StockSku {
  final String? id;
  final String? styleNo;
  final String? productName;
  final String? colorName;
  final String? sizeName;
  final int? stockQty;
  final int? stockWarningQty;
  final bool? isWarning;

  StockSku({
    this.id,
    this.styleNo,
    this.productName,
    this.colorName,
    this.sizeName,
    this.stockQty,
    this.stockWarningQty,
    this.isWarning,
  });

  factory StockSku.fromJson(Map<String, dynamic> json) {
    return StockSku(
      id: json['id'] as String?,
      styleNo: json['styleNo'] as String?,
      productName: json['productName'] as String?,
      colorName: json['colorName'] as String?,
      sizeName: json['sizeName'] as String?,
      stockQty: json['stockQty'] as int?,
      stockWarningQty: json['stockWarningQty'] as int?,
      isWarning: json['isWarning'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'styleNo': styleNo,
      'productName': productName,
      'colorName': colorName,
      'sizeName': sizeName,
      'stockQty': stockQty,
      'stockWarningQty': stockWarningQty,
      'isWarning': isWarning,
    };
  }

  StockSku copyWith({
    String? id,
    String? styleNo,
    String? productName,
    String? colorName,
    String? sizeName,
    int? stockQty,
    int? stockWarningQty,
    bool? isWarning,
  }) {
    return StockSku(
      id: id ?? this.id,
      styleNo: styleNo ?? this.styleNo,
      productName: productName ?? this.productName,
      colorName: colorName ?? this.colorName,
      sizeName: sizeName ?? this.sizeName,
      stockQty: stockQty ?? this.stockQty,
      stockWarningQty: stockWarningQty ?? this.stockWarningQty,
      isWarning: isWarning ?? this.isWarning,
    );
  }
}
