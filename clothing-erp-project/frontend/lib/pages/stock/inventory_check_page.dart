import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/stock_provider.dart';
import 'package:clothing_erp/providers/product_provider.dart';
import 'package:clothing_erp/utils/constants.dart';

class InventoryCheckPage extends StatefulWidget {
  const InventoryCheckPage({super.key});

  @override
  State<InventoryCheckPage> createState() => _InventoryCheckPageState();
}

class _InventoryCheckPageState extends State<InventoryCheckPage> {
  String _checkScope = 'all';
  final List<_CheckItem> _checkItems = [];
  final _barcodeController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _handleBarcodeInput(String barcode) async {
    if (barcode.isEmpty) return;

    final productProvider = context.read<ProductProvider>();
    final product = await productProvider.searchByBarcode(barcode);

    if (!mounted) return;

    if (product != null && product.skus != null) {
      for (final sku in product.skus!) {
        final existingIndex = _checkItems.indexWhere(
          (i) => i.skuId == sku.id,
        );
        if (existingIndex >= 0) {
          setState(() {
            _checkItems[existingIndex].actualQty++;
          });
        } else {
          setState(() {
            _checkItems.add(_CheckItem(
              skuId: sku.id ?? '',
              styleNo: product.styleNo ?? '',
              productName: product.name ?? '',
              colorName: sku.colorName ?? '',
              sizeName: sku.sizeName ?? '',
              systemQty: sku.stockQty ?? 0,
              actualQty: 1,
            ));
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('未找到条码 $barcode 对应的商品')),
      );
    }
    _barcodeController.clear();
  }

  void _showManualInputDialog(int index) {
    final controller = TextEditingController(
      text: _checkItems[index].actualQty.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_checkItems[index].productName ?? ''),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '实盘数量',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(controller.text) ?? 0;
              setState(() {
                _checkItems[index].actualQty = qty;
              });
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_checkItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请添加盘点商品')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('提交盘点'),
        content: Text('共 ${_checkItems.length} 项商品，确认提交盘点？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认提交'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final checkData = {
      'scope': _checkScope,
      'items': _checkItems.map((e) => e.toJson()).toList(),
    };

    final stockProvider = context.read<StockProvider>();
    final success = await stockProvider.createInventoryCheck(checkData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('盘点提交成功'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(stockProvider.error ?? '提交失败'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('库存盘点'),
        actions: [
          TextButton(
            onPressed: _handleSubmit,
            child: const Text('提交', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '盘点范围',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('全部商品'),
                      selected: _checkScope == 'all',
                      onSelected: (selected) {
                        if (selected) setState(() => _checkScope = 'all');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('按款号'),
                      selected: _checkScope == 'styleNo',
                      onSelected: (selected) {
                        if (selected) setState(() => _checkScope = 'styleNo');
                      },
                    ),
                    ChoiceChip(
                      label: const Text('按分类'),
                      selected: _checkScope == 'category',
                      onSelected: (selected) {
                        if (selected) setState(() => _checkScope = 'category');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '扫码或输入条码',
                prefixIcon: const Icon(Icons.qr_code_scanner),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () => _handleBarcodeInput(_barcodeController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onSubmitted: _handleBarcodeInput,
            ),
          ),
          Expanded(
            child: _checkItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fact_check_outlined,
                            size: 64, color: AppTheme.textHintColor),
                        SizedBox(height: 16),
                        Text('扫码或手工录入实盘数',
                            style: TextStyle(
                                color: AppTheme.textHintColor, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _checkItems.length,
                    itemBuilder: (context, index) {
                      final item = _checkItems[index];
                      final diff = item.actualQty - item.systemQty;
                      final hasDiff = diff != 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(
                            '${item.styleNo} - ${item.productName}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            '${item.colorName} / ${item.sizeName}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('系统: ',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme
                                                  .textHintColor)),
                                      Text('${item.systemQty}',
                                          style: const TextStyle(
                                              fontSize: 14)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('实盘: ',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme
                                                  .textHintColor)),
                                      GestureDetector(
                                        onTap: () =>
                                            _showManualInputDialog(index),
                                        child: Text(
                                          '${item.actualQty}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: hasDiff
                                                ? AppTheme.errorColor
                                                : AppTheme
                                                    .successColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (hasDiff)
                                    Text(
                                      diff > 0
                                          ? '盘盈 +$diff'
                                          : '盘亏 $diff',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: diff > 0
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor,
                                      ),
                                    ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () =>
                                    _showManualInputDialog(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CheckItem {
  final String skuId;
  final String styleNo;
  final String productName;
  final String colorName;
  final String sizeName;
  final int systemQty;
  int actualQty;

  _CheckItem({
    required this.skuId,
    required this.styleNo,
    required this.productName,
    required this.colorName,
    required this.sizeName,
    required this.systemQty,
    required this.actualQty,
  });

  Map<String, dynamic> toJson() {
    return {
      'skuId': skuId,
      'styleNo': styleNo,
      'productName': productName,
      'colorName': colorName,
      'sizeName': sizeName,
      'systemQty': systemQty,
      'actualQty': actualQty,
    };
  }
}
