import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/purchase_provider.dart';
import 'package:clothing_erp/providers/product_provider.dart';
import 'package:clothing_erp/utils/formatter.dart';
import 'package:clothing_erp/widgets/common/loading_widget.dart';
import 'package:clothing_erp/widgets/common/empty_widget.dart';

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  final List<_PurchaseItem> _items = [];
  final _supplierController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PurchaseProvider>().loadPurchaseOrders();
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double get _totalAmount => _items.fold(0, (sum, item) => sum + item.subtotal);

  void _showAddItemDialog() async {
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
              child: Text('选择商品', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        children: (product.skus ?? []).map((sku) {
                          return ListTile(
                            title: Text('${sku.colorName} / ${sku.sizeName}'),
                            trailing: Text(
                              '¥${sku.purchasePrice?.toStringAsFixed(2) ?? "0.00"}',
                              style: const TextStyle(color: AppTheme.accentColor),
                            ),
                            onTap: () {
                              setState(() {
                                final existing = _items.where(
                                  (i) => i.skuId == sku.id,
                                ).firstOrNull;
                                if (existing != null) {
                                  existing.quantity++;
                                } else {
                                  _items.add(_PurchaseItem(
                                    skuId: sku.id ?? '',
                                    styleNo: product.styleNo ?? '',
                                    productName: product.name ?? '',
                                    colorName: sku.colorName ?? '',
                                    sizeName: sku.sizeName ?? '',
                                    price: sku.purchasePrice ?? 0,
                                    quantity: 1,
                                  ));
                                }
                              });
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

  Future<void> _handleSubmit() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请添加商品')),
      );
      return;
    }

    final orderData = {
      'supplierName': _supplierController.text.trim(),
      'items': _items.map((e) => e.toJson()).toList(),
      'totalAmount': _totalAmount,
    };

    final purchaseProvider = context.read<PurchaseProvider>();
    final success = await purchaseProvider.createPurchaseOrder(orderData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('入库单创建成功'), backgroundColor: AppTheme.successColor),
      );
      setState(() {
        _items.clear();
        _supplierController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(purchaseProvider.error ?? '创建失败'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseProvider = context.watch<PurchaseProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('采购入库'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '新建入库'),
              Tab(text: '入库记录'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNewOrderTab(),
            _buildOrderListTab(purchaseProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildNewOrderTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _supplierController,
          decoration: const InputDecoration(
            labelText: '供应商',
            hintText: '请输入供应商名称（选填）',
            prefixIcon: Icon(Icons.local_shipping),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('商品列表', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加商品'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_items.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('点击"添加商品"开始', style: TextStyle(color: AppTheme.textHintColor)),
              ),
            ),
          )
        else
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Card(
              child: ListTile(
                title: Text('${item.styleNo} - ${item.productName}'),
                subtitle: Text('${item.colorName} / ${item.sizeName}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('¥${item.price.toStringAsFixed(2)} × ${item.quantity}'),
                        Text(
                          '¥${item.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 20),
                      onPressed: () {
                        setState(() {
                          _items.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        if (_items.isNotEmpty) ...[
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('合计:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '¥${FormatterUtil.formatAmount(_totalAmount)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('确认入库'),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderListTab(PurchaseProvider purchaseProvider) {
    return purchaseProvider.isLoading && purchaseProvider.purchaseOrders.isEmpty
        ? const LoadingWidget()
        : purchaseProvider.purchaseOrders.isEmpty
            ? const EmptyWidget(message: '暂无入库记录')
            : RefreshIndicator(
                onRefresh: () => purchaseProvider.loadPurchaseOrders(refresh: true),
                child: ListView.builder(
                  itemCount: purchaseProvider.purchaseOrders.length,
                  itemBuilder: (context, index) {
                    final order = purchaseProvider.purchaseOrders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.successColor,
                          child: Icon(Icons.inventory, color: Colors.white),
                        ),
                        title: Text(order.orderNo ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order.supplierName != null)
                              Text('供应商: ${order.supplierName}'),
                            Text(
                              order.createdAt ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '¥${FormatterUtil.formatAmount(order.totalAmount ?? 0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
  }
}

class _PurchaseItem {
  final String skuId;
  final String styleNo;
  final String productName;
  final String colorName;
  final String sizeName;
  final double price;
  int quantity;

  _PurchaseItem({
    required this.skuId,
    required this.styleNo,
    required this.productName,
    required this.colorName,
    required this.sizeName,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

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
