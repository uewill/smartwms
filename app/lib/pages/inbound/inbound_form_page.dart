import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';

class InboundItem {
  final String id;
  final String productId;
  final String productName;
  final String? productCode;
  final int quantity;
  final double price;

  InboundItem({
    this.id = '',
    required this.productId,
    required this.productName,
    this.productCode,
    this.quantity = 1,
    this.price = 0.0,
  });

  double get amount => price * quantity;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'productCode': productCode,
    'quantity': quantity,
    'price': price,
  };
}

class InboundFormPage extends StatefulWidget {
  const InboundFormPage({super.key});

  @override
  State<InboundFormPage> createState() => _InboundFormPageState();
}

class _InboundFormPageState extends State<InboundFormPage> {
  final _supplierController = TextEditingController();
  List<Warehouse> _warehouses = [];
  Warehouse? _selectedWarehouse;
  List<Product> _products = [];
  List<InboundItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final whResponse = await WarehouseService().getWarehouses();
      setState(() {
        _warehouses = whResponse;
        if (_warehouses.isNotEmpty) _selectedWarehouse = _warehouses.first;
      });

      final pdResponse = await ProductService().getProducts();
      setState(() {
        _products = pdResponse;
      });
    } catch (e) {
      debugPrint('Load data error: $e');
    }
  }

  void _addItem(Product product) {
    setState(() {
      final existing = _items.indexWhere((i) => i.productId == product.id);
      if (existing >= 0) {
        final item = _items[existing];
        _items[existing] = InboundItem(
          id: item.id,
          productId: product.id,
          productName: product.name,
          productCode: product.code,
          quantity: item.quantity + 1,
          price: product.costPrice,
        );
      } else {
        _items.add(InboundItem(
          productId: product.id,
          productName: product.name,
          productCode: product.code,
          quantity: 1,
          price: product.costPrice,
        ));
      }
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      _removeItem(index);
      return;
    }
    setState(() {
      final item = _items[index];
      _items[index] = InboundItem(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        productCode: item.productCode,
        quantity: quantity,
        price: item.price,
      );
    });
  }

  double get _totalAmount => _items.fold(0.0, (sum, item) => sum + item.amount);
  int get _totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> _submit() async {
    if (_selectedWarehouse == null) {
      _showError('请选择仓库');
      return;
    }
    if (_items.isEmpty) {
      _showError('请添加商品');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await InboundService().createOrder(
        warehouseId: _selectedWarehouse!.id,
        warehouseName: _selectedWarehouse!.name,
        items: _items.map((e) => e.toJson()).toList(),
        remark: _supplierController.text,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('提交成功')));
          Navigator.pop(context);
        }
      } else {
        _showError('提交失败');
      }
    } catch (e) {
      _showError('提交失败');
    }

    setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新增入库单')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection('基本信息', [
                  _buildWarehouseSelector(),
                  const SizedBox(height: 12),
                  TextField(controller: _supplierController, decoration: const InputDecoration(labelText: '供应商', border: OutlineInputBorder())),
                ]),
                const SizedBox(height: 16),
                _buildSection('入库商品', [
                  if (_products.isNotEmpty) _buildProductSelector(),
                  if (_items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('请添加商品', style: TextStyle(color: Color(0xFF86909C)))),
                    ),
                  ..._items.asMap().entries.map((e) => _buildItemCard(e.key, e.value)),
                ]),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('合计', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('$_totalQuantity 件  ¥${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF165DFF))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B42A)),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('提交入库单'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16), child: Column(children: children, crossAxisAlignment: CrossAxisAlignment.start)),
        ],
      ),
    );
  }

  Widget _buildWarehouseSelector() {
    return DropdownButtonFormField<Warehouse>(
      value: _selectedWarehouse,
      decoration: const InputDecoration(labelText: '入库仓库', border: OutlineInputBorder()),
      items: _warehouses.map((w) => DropdownMenuItem(value: w, child: Text(w.name))).toList(),
      onChanged: (v) => setState(() => _selectedWarehouse = v),
    );
  }

  Widget _buildProductSelector() {
    return GestureDetector(
      onTap: () => _showProductPicker(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E6EB)), borderRadius: BorderRadius.circular(8)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add, color: Color(0xFF165DFF)),
          SizedBox(width: 8),
          Text('添加商品', style: TextStyle(color: Color(0xFF165DFF), fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  void _showProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('选择商品', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx))])),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: _products.length,
                itemBuilder: (_, i) {
                  final p = _products[i];
                  return ListTile(
                    leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF165DFF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.inventory_2, color: Color(0xFF165DFF))),
                    title: Text(p.name),
                    subtitle: Text('${p.code} | ¥${p.costPrice.toStringAsFixed(2)}'),
                    trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF165DFF)),
                    onTap: () {
                      _addItem(p);
                      Navigator.pop(ctx);
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

  Widget _buildItemCard(int index, InboundItem item) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF2F3F5), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('¥${item.price.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF86909C), fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _updateQuantity(index, item.quantity - 1), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              SizedBox(width: 32, child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _updateQuantity(index, item.quantity + 1), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            ],
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text('¥${item.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF165DFF)), textAlign: TextAlign.right),
          ),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _removeItem(index), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ],
      ),
    );
  }
}
