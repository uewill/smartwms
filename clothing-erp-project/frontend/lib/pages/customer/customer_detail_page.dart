import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/customer_provider.dart';
import 'package:clothing_erp/utils/formatter.dart';

class CustomerDetailPage extends StatefulWidget {
  final String? customerId;

  const CustomerDetailPage({super.key, this.customerId});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      context.read<CustomerProvider>().loadCustomerDetail(widget.customerId!);
    }
  }

  void _showCollectDebtDialog() {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('收款'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '当前欠款: ¥${FormatterUtil.formatAmount(context.read<CustomerProvider>().currentCustomer?.totalDebt ?? 0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '收款金额',
                prefixText: '¥',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) return;

              final customerProvider = context.read<CustomerProvider>();
              final success = await customerProvider.collectDebt(
                widget.customerId!,
                amount,
              );

              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('收款成功'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(customerProvider.error ?? '收款失败'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text('确认收款'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final customer = customerProvider.currentCustomer;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer?.name ?? '客户详情'),
      ),
      body: customerProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : customer == null
              ? const Center(child: Text('客户不存在'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      AppTheme.primaryColor.withOpacity(0.1),
                                  child: Text(
                                    customer.name?.substring(0, 1) ?? '?',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.name ?? '',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        FormatterUtil.maskPhone(customer.phone),
                                        style: const TextStyle(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                      if (customer.remark != null &&
                                          customer.remark!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          '备注: ${customer.remark}',
                                          style: const TextStyle(
                                            color: AppTheme.textHintColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '欠款总额',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: (customer.totalDebt ?? 0) > 0
                                      ? _showCollectDebtDialog
                                      : null,
                                  icon: const Icon(Icons.payment, size: 18),
                                  label: const Text('收款'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '¥${FormatterUtil.formatAmount(customer.totalDebt ?? 0)}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: (customer.totalDebt ?? 0) > 0
                                    ? AppTheme.errorColor
                                    : AppTheme.successColor,
                              ),
                            ),
                            if (customer.lastPurchaseAt != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '最近购买: ${customer.lastPurchaseAt}',
                                style: const TextStyle(
                                  color: AppTheme.textHintColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '欠款明细',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (customerProvider.debtDetails.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('暂无欠款记录',
                                style: TextStyle(color: AppTheme.textHintColor)),
                          ),
                        ),
                      )
                    else
                      ...customerProvider.debtDetails.map((debt) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.receipt_long,
                                  color: AppTheme.errorColor),
                              title: Text(debt.orderNo ?? ''),
                              subtitle: debt.createdAt != null
                                  ? Text(debt.createdAt!,
                                      style: const TextStyle(fontSize: 12))
                                  : null,
                              trailing: Text(
                                '¥${FormatterUtil.formatAmount(debt.amount ?? 0)}',
                                style: const TextStyle(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )),
                  ],
                ),
    );
  }
}
