import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/sale_provider.dart';
import 'package:clothing_erp/providers/customer_provider.dart';
import 'package:clothing_erp/utils/constants.dart';
import 'package:clothing_erp/utils/formatter.dart';
import 'package:clothing_erp/widgets/sale/cart_item_widget.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [];
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  double _discount = 1.0;
  double _eraseAmount = 0;
  String? _selectedCustomerId;
  String? _selectedCustomerName;
  final _discountController = TextEditingController();
  final _eraseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerProvider>().loadCustomers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  double get _subtotal => _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get _totalAfterDiscount => _subtotal * _discount - _eraseAmount;
  double get _finalAmount => _totalAfterDiscount < 0 ? 0 : _totalAfterDiscount;

  void _showDiscountDialog() {
    _discountController.text = (_discount * 100).toStringAsFixed(0);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('整单折扣'),
        content: TextField(
          controller: _discountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '折扣（%）',
            hintText: '例如：95 表示95折',
            suffixText: '%',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(_discountController.text);
              if (val != null && val > 0 && val <= 100) {
                setState(() {
                  _discount = val / 100;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showEraseDialog() {
    _eraseController.text = _eraseAmount.toStringAsFixed(2);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('抹零'),
        content: TextField(
          controller: _eraseController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '抹零金额',
            prefixText: '¥',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(_eraseController.text) ?? 0;
              setState(() {
                _eraseAmount = val;
              });
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showCustomerSelector() {
    final customerProvider = context.read<CustomerProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('选择客户', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: customerProvider.customers.length,
                itemBuilder: (_, index) {
                  final customer = customerProvider.customers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(customer.name?.substring(0, 1) ?? '?'),
                    ),
                    title: Text(customer.name ?? ''),
                    subtitle: Text(customer.phone ?? ''),
                    trailing: customer.totalDebt != null && customer.totalDebt! > 0
                        ? Text(
                            '欠款: ¥${FormatterUtil.formatAmount(customer.totalDebt!)}',
                            style: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
                          )
                        : null,
                    selected: customer.id == _selectedCustomerId,
                    onTap: () {
                      setState(() {
                        _selectedCustomerId = customer.id;
                        _selectedCustomerName = customer.name;
                      });
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

  Future<void> _handleCheckout() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('购物车为空')),
      );
      return;
    }

    if (_paymentMethod == PaymentMethod.credit && _selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('赊账请选择客户')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认结算'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('商品数量: ${_cartItems.fold(0, (sum, item) => sum + item.quantity)}件'),
            const SizedBox(height: 8),
            Text('商品总额: ¥${FormatterUtil.formatAmount(_subtotal)}'),
            if (_discount < 1) Text('折扣: ${(_discount * 100).toStringAsFixed(0)}%'),
            if (_eraseAmount > 0) Text('抹零: ¥${_eraseAmount.toStringAsFixed(2)}'),
            const Divider(),
            Text(
              '实收: ¥${FormatterUtil.formatAmount(_finalAmount)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentColor),
            ),
            const SizedBox(height: 8),
            Text('支付方式: ${_paymentMethod.label}'),
            if (_selectedCustomerName != null)
              Text('客户: $_selectedCustomerName'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认结算')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final saleProvider = context.read<SaleProvider>();
    final orderData = {
      'items': _cartItems.map((e) => e.toOrderItemJson()).toList(),
      'totalAmount': _subtotal,
      'actualAmount': _finalAmount,
      'discount': _discount,
      'eraseAmount': _eraseAmount,
      'paymentMethod': _paymentMethod.value,
      if (_selectedCustomerId != null) 'customerId': _selectedCustomerId,
      if (_selectedCustomerName != null) 'customerName': _selectedCustomerName,
    };

    final success = await saleProvider.createSaleOrder(orderData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('结算成功'), backgroundColor: AppTheme.successColor),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saleProvider.error ?? '结算失败'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<CartItem> && _cartItems.isEmpty) {
      _cartItems = List.from(args);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('购物车'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.textHintColor),
                        SizedBox(height: 16),
                        Text('购物车为空', style: TextStyle(color: AppTheme.textHintColor, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      TextButton.icon(
                        onPressed: _showDiscountDialog,
                        icon: const Icon(Icons.discount, size: 18),
                        label: const Text('折扣'),
                      ),
                      TextButton.icon(
                        onPressed: _showEraseDialog,
                        icon: const Icon(Icons.exposure_zero, size: 18),
                        label: const Text('抹零'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('支付方式', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: PaymentMethod.values.map((method) {
                          return ChoiceChip(
                            label: Text(method.label),
                            selected: _paymentMethod == method,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _paymentMethod = method;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      if (_paymentMethod == PaymentMethod.credit) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _showCustomerSelector,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.dividerColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCustomerName ?? '选择赊账客户',
                                  style: TextStyle(
                                    color: _selectedCustomerName != null
                                        ? AppTheme.textPrimaryColor
                                        : AppTheme.textHintColor,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_discount < 1 || _eraseAmount > 0)
                              Text(
                                '原价: ¥${FormatterUtil.formatAmount(_subtotal)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppTheme.textHintColor,
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              '实收: ¥${FormatterUtil.formatAmount(_finalAmount)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _handleCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                          ),
                          child: const Text('确认结算', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
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
