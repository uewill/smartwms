import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/product_provider.dart';
import 'package:clothing_erp/routes/app_routes.dart';
import 'package:clothing_erp/widgets/sale/cart_item_widget.dart';

class SaleOrderPage extends StatefulWidget {
  const SaleOrderPage({super.key});

  @override
  State<SaleOrderPage> createState() => _SaleOrderPageState();
}

class _SaleOrderPageState extends State<SaleOrderPage> {
  final List<CartItem> _cartItems = [];
  bool _isScanning = true;

  int get _cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get _cartTotal =>
      _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  void _addToCart(CartItem item) {
    final existingIndex = _cartItems.indexWhere(
      (i) => i.skuId == item.skuId,
    );
    if (existingIndex >= 0) {
      setState(() {
        _cartItems[existingIndex].quantity++;
      });
    } else {
      setState(() {
        _cartItems.add(item);
      });
    }
  }

  void _handleBarcodeScan(String barcode) async {
    final productProvider = context.read<ProductProvider>();
    final product = await productProvider.searchByBarcode(barcode);

    if (!mounted) return;

    if (product != null && product.skus != null && product.skus!.isNotEmpty) {
      final sku = product.skus!.first;
      _addToCart(CartItem(
        skuId: sku.id ?? '',
        styleNo: product.styleNo ?? '',
        productName: product.name ?? '',
        colorName: sku.colorName ?? '',
        sizeName: sku.sizeName ?? '',
        price: sku.retailPrice ?? 0,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('未找到条码 $barcode 对应的商品')),
      );
    }
  }

  void _showManualBarcodeInput() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('输入条码'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '请输入商品条码',
            prefixIcon: Icon(Icons.barcode_reader),
          ),
          onSubmitted: (value) {
            Navigator.pop(ctx);
            if (value.isNotEmpty) {
              _handleBarcodeScan(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (controller.text.isNotEmpty) {
                _handleBarcodeScan(controller.text);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showProductSelector() async {
    final productProvider = context.read<ProductProvider>();
    await productProvider.loadProducts(refresh: true);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择商品',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (_, provider, __) {
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: provider.products.length,
                    itemBuilder: (_, index) {
                      final product = provider.products[index];
                      return ExpansionTile(
                        title: Text('${product.styleNo} - ${product.name}'),
                        subtitle: Text(
                          '${product.colors?.length ?? 0}色 ${product.sizes?.length ?? 0}码',
                          style: const TextStyle(fontSize: 12),
                        ),
                        children: (product.skus ?? []).map((sku) {
                          return ListTile(
                            title: Text('${sku.colorName} / ${sku.sizeName}'),
                            trailing: Text(
                              '¥${sku.retailPrice?.toStringAsFixed(2) ?? "0.00"}',
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              _addToCart(CartItem(
                                skuId: sku.id ?? '',
                                styleNo: product.styleNo ?? '',
                                productName: product.name ?? '',
                                colorName: sku.colorName ?? '',
                                sizeName: sku.sizeName ?? '',
                                price: sku.retailPrice ?? 0,
                              ));
                              Navigator.pop(ctx);
                            },
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开单'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.cart, arguments: _cartItems);
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.errorColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$_cartItemCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            color: Colors.black,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 80,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '将条码对准扫描区域',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showManualBarcodeInput,
                        icon: const Icon(Icons.keyboard),
                        label: const Text('手动输入条码'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showProductSelector,
                          icon: const Icon(Icons.checkroom),
                          label: const Text('手工选款'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_shopping_cart, size: 48, color: AppTheme.textHintColor),
                        SizedBox(height: 12),
                        Text('扫码或手工添加商品', style: TextStyle(color: AppTheme.textHintColor)),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('已添加 ${_cartItems.length} 件商品'),
                            Text(
                              '合计: ¥${_cartTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return CartItemWidget(
                              item: item,
                              onIncrement: () {
                                setState(() {
                                  _cartItems[index].quantity++;
                                });
                              },
                              onDecrement: () {
                                setState(() {
                                  if (_cartItems[index].quantity > 1) {
                                    _cartItems[index].quantity--;
                                  } else {
                                    _cartItems.removeAt(index);
                                  }
                                });
                              },
                              onDelete: () {
                                setState(() {
                                  _cartItems.removeAt(index);
                                });
                              },
                              onPriceChanged: (newPrice) {
                                setState(() {
                                  _cartItems[index].price = newPrice;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.cart,
                              arguments: _cartItems,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: const Text('去结算'),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
