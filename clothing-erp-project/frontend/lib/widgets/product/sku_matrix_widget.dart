import 'package:flutter/material.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/models/product.dart';

class SkuMatrixWidget extends StatelessWidget {
  final List<String> colors;
  final List<String> sizes;
  final List<ProductSku> skus;
  final bool editable;
  final ValueChanged<ProductSku>? onPriceChanged;
  final String priceField;

  const SkuMatrixWidget({
    super.key,
    required this.colors,
    required this.sizes,
    required this.skus,
    this.editable = false,
    this.onPriceChanged,
    this.priceField = 'retailPrice',
  });

  double? _getPrice(String color, String size) {
    final sku = skus.where(
      (s) => s.colorName == color && s.sizeName == size,
    ).firstOrNull;
    if (sku == null) return null;
    switch (priceField) {
      case 'wholesalePrice':
        return sku.wholesalePrice;
      case 'purchasePrice':
        return sku.purchasePrice;
      default:
        return sku.retailPrice;
    }
  }

  int? _getStock(String color, String size) {
    final sku = skus.where(
      (s) => s.colorName == color && s.sizeName == size,
    ).firstOrNull;
    return sku?.stockQty;
  }

  ProductSku? _getSku(String color, String size) {
    return skus.where(
      (s) => s.colorName == color && s.sizeName == size,
    ).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty || sizes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('请先选择颜色和尺码', style: TextStyle(color: AppTheme.textHintColor)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 4,
          horizontalMargin: 8,
          headingRowHeight: 40,
          dataRowHeight: 48,
          columns: [
            const DataColumn(
              label: Text('颜色', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            ...sizes.map((size) => DataColumn(
              label: Text(size, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            )),
          ],
          rows: colors.map((color) {
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(color, style: const TextStyle(fontSize: 13)),
                  ),
                ),
                ...sizes.map((size) {
                  final price = _getPrice(color, size);
                  final stock = _getStock(color, size);
                  final sku = _getSku(color, size);

                  return DataCell(
                    GestureDetector(
                      onTap: editable && sku != null && onPriceChanged != null
                          ? () => _showPriceEditor(context, sku)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: sku != null
                              ? (stock != null && stock <= 0
                                  ? AppTheme.warningColor.withOpacity(0.1)
                                  : AppTheme.primaryColor.withOpacity(0.05))
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (price != null)
                              Text(
                                '¥${price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: editable ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                                ),
                              ),
                            if (stock != null)
                              Text(
                                '库存:$stock',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: stock <= 0
                                      ? AppTheme.errorColor
                                      : AppTheme.textSecondaryColor,
                                ),
                              ),
                            if (sku == null)
                              const Text(
                                '-',
                                style: TextStyle(color: AppTheme.textHintColor, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPriceEditor(BuildContext context, ProductSku sku) {
    final priceController = TextEditingController(
      text: priceField == 'wholesalePrice'
          ? (sku.wholesalePrice?.toStringAsFixed(2) ?? '')
          : priceField == 'purchasePrice'
              ? (sku.purchasePrice?.toStringAsFixed(2) ?? '')
              : (sku.retailPrice?.toStringAsFixed(2) ?? ''),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${sku.colorName} / ${sku.sizeName}'),
        content: TextField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: priceField == 'wholesalePrice'
                ? '批发价'
                : priceField == 'purchasePrice'
                    ? '进货价'
                    : '零售价',
            prefixText: '¥',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(priceController.text);
              if (newPrice != null && onPriceChanged != null) {
                final updatedSku = sku.copyWith(
                  retailPrice: priceField == 'retailPrice' ? newPrice : null,
                  wholesalePrice: priceField == 'wholesalePrice' ? newPrice : null,
                  purchasePrice: priceField == 'purchasePrice' ? newPrice : null,
                );
                onPriceChanged!(updatedSku);
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
