import 'package:flutter/material.dart';
import 'package:clothing_erp/config/theme.dart';

class CartItem {
  final String skuId;
  final String styleNo;
  final String productName;
  final String colorName;
  final String sizeName;
  double price;
  int quantity;

  CartItem({
    required this.skuId,
    required this.styleNo,
    required this.productName,
    this.colorName = '',
    this.sizeName = '',
    required this.price,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toOrderItemJson() {
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

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onDelete;
  final ValueChanged<double>? onPriceChanged;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onIncrement,
    this.onDecrement,
    this.onDelete,
    this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.skuId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.styleNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (item.colorName.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.colorName,
                              style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor),
                            ),
                          ),
                        const SizedBox(width: 6),
                        if (item.sizeName.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.sizeName,
                              style: const TextStyle(fontSize: 12, color: AppTheme.accentColor),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showPriceEditor(context),
                      child: Row(
                        children: [
                          Text(
                            '¥${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, size: 14, color: AppTheme.textHintColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onTap: onDecrement,
                      ),
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add,
                        onTap: onIncrement,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¥${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textSecondaryColor),
      ),
    );
  }

  void _showPriceEditor(BuildContext context) {
    final priceController = TextEditingController(
      text: item.price.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改单价'),
        content: TextField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '单价',
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
              if (newPrice != null && newPrice > 0 && onPriceChanged != null) {
                onPriceChanged!(newPrice);
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
