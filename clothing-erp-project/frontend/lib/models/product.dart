class ProductSku {
  final String? id;
  final String? colorName;
  final String? sizeName;
  final String? barcode;
  final double? retailPrice;
  final double? wholesalePrice;
  final double? purchasePrice;
  final int? stockQty;

  ProductSku({
    this.id,
    this.colorName,
    this.sizeName,
    this.barcode,
    this.retailPrice,
    this.wholesalePrice,
    this.purchasePrice,
    this.stockQty,
  });

  factory ProductSku.fromJson(Map<String, dynamic> json) {
    return ProductSku(
      id: json['id'] as String?,
      colorName: json['colorName'] as String?,
      sizeName: json['sizeName'] as String?,
      barcode: json['barcode'] as String?,
      retailPrice: (json['retailPrice'] as num?)?.toDouble(),
      wholesalePrice: (json['wholesalePrice'] as num?)?.toDouble(),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      stockQty: json['stockQty'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'colorName': colorName,
      'sizeName': sizeName,
      'barcode': barcode,
      'retailPrice': retailPrice,
      'wholesalePrice': wholesalePrice,
      'purchasePrice': purchasePrice,
      'stockQty': stockQty,
    };
  }

  ProductSku copyWith({
    String? id,
    String? colorName,
    String? sizeName,
    String? barcode,
    double? retailPrice,
    double? wholesalePrice,
    double? purchasePrice,
    int? stockQty,
  }) {
    return ProductSku(
      id: id ?? this.id,
      colorName: colorName ?? this.colorName,
      sizeName: sizeName ?? this.sizeName,
      barcode: barcode ?? this.barcode,
      retailPrice: retailPrice ?? this.retailPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      stockQty: stockQty ?? this.stockQty,
    );
  }
}

class Product {
  final String? id;
  final String? styleNo;
  final String? name;
  final String? brand;
  final String? season;
  final String? imageUrl;
  final String? thumbUrl;
  final List<String>? colors;
  final List<String>? sizes;
  final List<ProductSku>? skus;

  Product({
    this.id,
    this.styleNo,
    this.name,
    this.brand,
    this.season,
    this.imageUrl,
    this.thumbUrl,
    this.colors,
    this.sizes,
    this.skus,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String?,
      styleNo: json['styleNo'] as String?,
      name: json['name'] as String?,
      brand: json['brand'] as String?,
      season: json['season'] as String?,
      imageUrl: json['imageUrl'] as String?,
      thumbUrl: json['thumbUrl'] as String?,
      colors: (json['colors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sizes: (json['sizes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      skus: (json['skus'] as List<dynamic>?)
          ?.map((e) => ProductSku.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'styleNo': styleNo,
      'name': name,
      'brand': brand,
      'season': season,
      'imageUrl': imageUrl,
      'thumbUrl': thumbUrl,
      'colors': colors,
      'sizes': sizes,
      'skus': skus?.map((e) => e.toJson()).toList(),
    };
  }

  Product copyWith({
    String? id,
    String? styleNo,
    String? name,
    String? brand,
    String? season,
    String? imageUrl,
    String? thumbUrl,
    List<String>? colors,
    List<String>? sizes,
    List<ProductSku>? skus,
  }) {
    return Product(
      id: id ?? this.id,
      styleNo: styleNo ?? this.styleNo,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      season: season ?? this.season,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      colors: colors ?? this.colors,
      sizes: sizes ?? this.sizes,
      skus: skus ?? this.skus,
    );
  }
}
