import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/auth_provider.dart';
import 'package:clothing_erp/providers/shop_provider.dart';
import 'package:clothing_erp/providers/sale_provider.dart';
import 'package:clothing_erp/providers/product_provider.dart';
import 'package:clothing_erp/providers/stock_provider.dart';
import 'package:clothing_erp/utils/formatter.dart';
import 'package:clothing_erp/routes/app_routes.dart';
import 'package:clothing_erp/widgets/common/loading_widget.dart';
import 'package:clothing_erp/widgets/common/empty_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final shopProvider = context.read<ShopProvider>();
    final saleProvider = context.read<SaleProvider>();
    final productProvider = context.read<ProductProvider>();
    final stockProvider = context.read<StockProvider>();

    await Future.wait([
      shopProvider.loadShops(),
      saleProvider.loadTodaySummary(),
      productProvider.loadProducts(),
      stockProvider.loadStockList(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _SaleTab(),
          _ProductTab(),
          _StockTab(),
          _MineTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            activeIcon: Icon(Icons.receipt_long),
            label: '开单',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            activeIcon: Icon(Icons.checkroom),
            label: '商品',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: '库存',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class _SaleTab extends StatelessWidget {
  const _SaleTab();

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.watch<ShopProvider>();
    final saleProvider = context.watch<SaleProvider>();
    final summary = saleProvider.todaySummary;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _showShopSwitcher(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(shopProvider.currentShop?.name ?? '选择店铺'),
              const SizedBox(width: 4),
              const Icon(Icons.swap_horiz, size: 20),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => saleProvider.loadTodaySummary(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日概览',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: '销售额',
                            value: '¥${FormatterUtil.formatAmount(summary?.totalSales ?? 0)}',
                            icon: Icons.attach_money,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: '毛利',
                            value: '¥${FormatterUtil.formatAmount(summary?.totalProfit ?? 0)}',
                            icon: Icons.trending_up,
                            color: AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: '订单数',
                            value: '${summary?.orderCount ?? 0}',
                            icon: Icons.receipt,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '快捷操作',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.qr_code_scanner,
                    label: '扫码开单',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.saleOrder);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.edit_note,
                    label: '手工开单',
                    color: AppTheme.accentColor,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.saleOrder, arguments: 'manual');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.add_shopping_cart,
                    label: '采购入库',
                    color: AppTheme.successColor,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.purchaseOrder);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.fact_check,
                    label: '库存盘点',
                    color: const Color(0xFF7B1FA2),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.inventoryCheck);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShopSwitcher(BuildContext context) {
    final shopProvider = context.read<ShopProvider>();
    final shops = shopProvider.shops;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '切换店铺',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...shops.map((shop) => ListTile(
              leading: Icon(
                shop.id == shopProvider.currentShop?.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: AppTheme.primaryColor,
              ),
              title: Text(shop.name ?? ''),
              subtitle: shop.address != null ? Text(shop.address!, style: const TextStyle(fontSize: 12)) : null,
              onTap: () {
                if (shop.id != null) {
                  shopProvider.switchShop(shop.id!);
                }
                Navigator.pop(ctx);
              },
            )),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showCreateShopDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('创建店铺'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showJoinShopDialog(context);
                      },
                      icon: const Icon(Icons.group_add),
                      label: const Text('加入店铺'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateShopDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('创建店铺'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '店铺名称', hintText: '请输入店铺名称'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: '店铺地址', hintText: '请输入店铺地址（选填）'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<ShopProvider>().createShop(
                      nameController.text.trim(),
                      address: addressController.text.trim(),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showJoinShopDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('加入店铺'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: '邀请码',
            hintText: '请输入店铺邀请码',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.trim().isNotEmpty) {
                context.read<ShopProvider>().joinShop(codeController.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('加入'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductTab extends StatelessWidget {
  const _ProductTab();

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('商品'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ProductSearchDelegate(productProvider),
              );
            },
          ),
        ],
      ),
      body: productProvider.isLoading && productProvider.products.isEmpty
          ? const LoadingWidget()
          : productProvider.products.isEmpty
              ? EmptyWidget(
                  message: '暂无商品',
                  icon: Icons.checkroom,
                  onAction: () {
                    Navigator.pushNamed(context, AppRoutes.productForm);
                  },
                  actionLabel: '添加商品',
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];
                    return _ProductGridItem(product: product);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.productForm);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ProductSearchDelegate extends SearchDelegate {
  final ProductProvider productProvider;

  _ProductSearchDelegate(this.productProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    productProvider.setKeyword(query);
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = query.isEmpty
        ? productProvider.products
        : productProvider.products
            .where((p) =>
                (p.styleNo?.contains(query) ?? false) ||
                (p.name?.contains(query) ?? false))
            .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _ProductGridItem(product: filtered[index]);
      },
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final dynamic product;

  const _ProductGridItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.productForm,
            arguments: product,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey.shade100,
                child: product.thumbUrl != null && product.thumbUrl!.isNotEmpty
                    ? Image.network(
                        product.thumbUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.checkroom,
                          size: 40,
                          color: AppTheme.textHintColor,
                        ),
                      )
                    : const Icon(
                        Icons.checkroom,
                        size: 40,
                        color: AppTheme.textHintColor,
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.styleNo ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (product.colors != null)
                          Text(
                            '${product.colors!.length}色',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textHintColor),
                          ),
                        if (product.sizes != null) ...[
                          const Text(' · ', style: TextStyle(fontSize: 11, color: AppTheme.textHintColor)),
                          Text(
                            '${product.sizes!.length}码',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textHintColor),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockTab extends StatelessWidget {
  const _StockTab();

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();
    final warningList = stockProvider.warningList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('库存'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _StockSearchDelegate(stockProvider),
              );
            },
          ),
        ],
      ),
      body: stockProvider.isLoading && stockProvider.stockList.isEmpty
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: () => stockProvider.loadStockList(refresh: true),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (warningList.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.warning, color: AppTheme.warningColor, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '库存预警 (${warningList.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...warningList.take(5).map((stock) => _StockItem(stock: stock, isWarning: true)),
                    if (warningList.length > 5)
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.stockList);
                        },
                        child: Text('查看全部 ${warningList.length} 项预警'),
                      ),
                    const Divider(height: 32),
                  ],
                  const Text(
                    '库存查询',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (stockProvider.stockList.isEmpty)
                    const EmptyWidget(message: '暂无库存数据')
                  else
                    ...stockProvider.stockList.take(20).map((stock) => _StockItem(stock: stock)),
                ],
              ),
            ),
    );
  }
}

class _StockSearchDelegate extends SearchDelegate {
  final StockProvider stockProvider;

  _StockSearchDelegate(this.stockProvider);

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
    stockProvider.loadStockList(refresh: true, styleNo: query);
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = query.isEmpty
        ? stockProvider.stockList
        : stockProvider.stockList
            .where((s) =>
                (s.styleNo?.contains(query) ?? false) ||
                (s.productName?.contains(query) ?? false))
            .toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) => _StockItem(stock: filtered[index]),
    );
  }
}

class _StockItem extends StatelessWidget {
  final dynamic stock;
  final bool isWarning;

  const _StockItem({required this.stock, this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isWarning ? AppTheme.warningColor.withOpacity(0.05) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isWarning
              ? AppTheme.warningColor.withOpacity(0.15)
              : AppTheme.primaryColor.withOpacity(0.1),
          child: Icon(
            isWarning ? Icons.warning : Icons.inventory_2,
            color: isWarning ? AppTheme.warningColor : AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          '${stock.styleNo ?? ''} - ${stock.productName ?? ''}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text('${stock.colorName ?? ''} / ${stock.sizeName ?? ''}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${stock.stockQty ?? 0}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isWarning ? AppTheme.errorColor : AppTheme.primaryColor,
              ),
            ),
            const Text('库存', style: TextStyle(fontSize: 10, color: AppTheme.textHintColor)),
          ],
        ),
      ),
    );
  }
}

class _MineTab extends StatelessWidget {
  const _MineTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final shopProvider = context.watch<ShopProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: ListView(
        children: [
          Container(
            color: AppTheme.primaryColor,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    user?.nickname?.substring(0, 1) ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.nickname ?? '未登录',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shopProvider.currentShop?.name ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _MenuSection(children: [
            _MenuItem(
              icon: Icons.people,
              title: '客户管理',
              onTap: () => Navigator.pushNamed(context, AppRoutes.customerList),
            ),
            _MenuItem(
              icon: Icons.add_shopping_cart,
              title: '采购入库',
              onTap: () => Navigator.pushNamed(context, AppRoutes.purchaseOrder),
            ),
            _MenuItem(
              icon: Icons.bar_chart,
              title: '报表',
              onTap: () => Navigator.pushNamed(context, AppRoutes.report),
            ),
          ]),
          const SizedBox(height: 8),
          _MenuSection(children: [
            _MenuItem(
              icon: Icons.store,
              title: '店铺管理',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            _MenuItem(
              icon: Icons.people_outline,
              title: '店员管理',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            _MenuItem(
              icon: Icons.card_membership,
              title: '订阅管理',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            _MenuItem(
              icon: Icons.compare_arrows,
              title: '版本对比',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ]),
          const SizedBox(height: 8),
          _MenuSection(children: [
            _MenuItem(
              icon: Icons.settings,
              title: '设置',
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('退出登录'),
                    content: const Text('确定要退出登录吗？'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
              ),
              child: const Text('退出登录'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> children;

  const _MenuSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textHintColor),
      onTap: onTap,
    );
  }
}
