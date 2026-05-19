import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/customer_provider.dart';
import 'package:clothing_erp/routes/app_routes.dart';
import 'package:clothing_erp/utils/formatter.dart';
import 'package:clothing_erp/widgets/common/loading_widget.dart';
import 'package:clothing_erp/widgets/common/empty_widget.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CustomerProvider>().loadCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CustomerProvider>().loadCustomers();
    }
  }

  void _showCreateCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final remarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建客户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '客户姓名', hintText: '请输入姓名'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: '手机号', hintText: '请输入手机号'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: remarkController,
              decoration: const InputDecoration(labelText: '备注', hintText: '请输入备注（选填）'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final success = await context.read<CustomerProvider>().createCustomer({
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
                'remark': remarkController.text.trim(),
              });
              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('创建失败')),
                  );
                }
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('客户管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _CustomerSearchDelegate(customerProvider),
              );
            },
          ),
        ],
      ),
      body: customerProvider.isLoading && customerProvider.customers.isEmpty
          ? const LoadingWidget()
          : customerProvider.customers.isEmpty
              ? EmptyWidget(
                  message: '暂无客户',
                  onAction: _showCreateCustomerDialog,
                  actionLabel: '添加客户',
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      customerProvider.loadCustomers(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: customerProvider.customers.length,
                    itemBuilder: (context, index) {
                      final customer = customerProvider.customers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(
                              customer.name?.substring(0, 1) ?? '?',
                              style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(customer.name ?? ''),
                          subtitle: Text(
                            FormatterUtil.maskPhone(customer.phone),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: customer.totalDebt != null &&
                                  customer.totalDebt! > 0
                              ? Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    const Text('欠款',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color:
                                                AppTheme.textHintColor)),
                                    Text(
                                      '¥${FormatterUtil.formatAmount(customer.totalDebt!)}',
                                      style: const TextStyle(
                                        color: AppTheme.errorColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                )
                              : const Icon(Icons.chevron_right,
                                  color: AppTheme.textHintColor),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.customerDetail,
                              arguments: customer.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCustomerDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _CustomerSearchDelegate extends SearchDelegate {
  final CustomerProvider customerProvider;

  _CustomerSearchDelegate(this.customerProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    customerProvider.loadCustomers(refresh: true, keyword: query);
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = query.isEmpty
        ? customerProvider.customers
        : customerProvider.customers
            .where((c) =>
                (c.name?.contains(query) ?? false) ||
                (c.phone?.contains(query) ?? false))
            .toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final customer = filtered[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(customer.name?.substring(0, 1) ?? '?'),
          ),
          title: Text(customer.name ?? ''),
          subtitle: Text(FormatterUtil.maskPhone(customer.phone)),
          trailing: customer.totalDebt != null && customer.totalDebt! > 0
              ? Text(
                  '¥${FormatterUtil.formatAmount(customer.totalDebt!)}',
                  style: const TextStyle(color: AppTheme.errorColor),
                )
              : null,
          onTap: () {
            close(context, customer.id);
            Navigator.pushNamed(
              context,
              AppRoutes.customerDetail,
              arguments: customer.id,
            );
          },
        );
      },
    );
  }
}
