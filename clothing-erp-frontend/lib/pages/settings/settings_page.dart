import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/auth_provider.dart';
import 'package:clothing_erp/providers/shop_provider.dart';
import 'package:clothing_erp/providers/subscription_provider.dart';
import 'package:clothing_erp/utils/constants.dart';
import 'package:clothing_erp/routes/app_routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionProvider>().loadSubscription();
    context.read<ShopProvider>().loadShops();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final shopProvider = context.watch<ShopProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final subscription = subscriptionProvider.subscription;
    final planType = subscription?.planType ?? 'free';

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _SectionTitle(title: '店铺管理'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.store, color: AppTheme.primaryColor),
                  title: const Text('当前店铺'),
                  subtitle: Text(shopProvider.currentShop?.name ?? '未选择'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showShopSwitcher(context),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.add_business, color: AppTheme.primaryColor),
                  title: const Text('创建店铺'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCreateShopDialog(context),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.group_add, color: AppTheme.primaryColor),
                  title: const Text('加入店铺'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showJoinShopDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: '店员管理'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: const Icon(Icons.people, color: AppTheme.primaryColor),
              title: const Text('店员列表'),
              subtitle: Text(
                subscriptionProvider.isFree ? '专业版功能' : '',
                style: const TextStyle(fontSize: 12, color: AppTheme.accentColor),
              ),
              trailing: subscriptionProvider.isFree
                  ? const Icon(Icons.lock, size: 18, color: AppTheme.textHintColor)
                  : const Icon(Icons.chevron_right),
              onTap: () {
                if (subscriptionProvider.isFree) {
                  _showUpgradeDialog(context, '店员管理');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('功能开发中')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: '订阅管理'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.card_membership,
                    color: planType == 'pro'
                        ? AppTheme.accentColor
                        : AppTheme.primaryColor,
                  ),
                  title: Text('当前版本: ${PlanType.getLabel(planType)}'),
                  subtitle: subscription?.endDate != null
                      ? Text('到期时间: ${subscription!.endDate}')
                      : null,
                  trailing: ElevatedButton(
                    onPressed: () => _showPlanCompare(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('升级'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: '版本对比'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => _showPlanCompare(context),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.compare_arrows, color: AppTheme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '查看版本对比',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '免费版 / 基础版 / 专业版',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: '其他'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  title: const Text('关于'),
                  subtitle: const Text('v1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: '服装ERP',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.checkroom, size: 48),
                      children: [const Text('服装小微ERP管理工具')],
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                  title: const Text('退出登录', style: TextStyle(color: AppTheme.errorColor)),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('退出登录'),
                        content: const Text('确定要退出登录吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('取消'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('确定'),
                          ),
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showShopSwitcher(BuildContext context) {
    final shopProvider = context.read<ShopProvider>();

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
              child: Text('切换店铺', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...shopProvider.shops.map((shop) => ListTile(
                  leading: Icon(
                    shop.id == shopProvider.currentShop?.id
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: AppTheme.primaryColor,
                  ),
                  title: Text(shop.name ?? ''),
                  subtitle: shop.address != null
                      ? Text(shop.address!, style: const TextStyle(fontSize: 12))
                      : null,
                  onTap: () {
                    if (shop.id != null) {
                      shopProvider.switchShop(shop.id!);
                    }
                    Navigator.pop(ctx);
                  },
                )),
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
              decoration: const InputDecoration(labelText: '店铺名称'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: '店铺地址（选填）'),
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
          decoration: const InputDecoration(labelText: '邀请码'),
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

  void _showPlanCompare(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '版本对比',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              _buildPlanCompareRow('功能', '免费版', '基础版', '专业版', isHeader: true),
              const Divider(),
              _buildPlanCompareRow('商品管理', '✓', '✓', '✓'),
              _buildPlanCompareRow('开单销售', '✓', '✓', '✓'),
              _buildPlanCompareRow('库存管理', '✓', '✓', '✓'),
              _buildPlanCompareRow('客户管理', '基础', '✓', '✓'),
              _buildPlanCompareRow('店铺数量', '1', '3', '不限'),
              _buildPlanCompareRow('店员管理', '✗', '✓', '✓'),
              _buildPlanCompareRow('热卖排行', '✗', '✓', '✓'),
              _buildPlanCompareRow('积压预警', '✗', '✗', '✓'),
              _buildPlanCompareRow('客户欠款', '✗', '✗', '✓'),
              _buildPlanCompareRow('利润分析', '✗', '✗', '✓'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('关闭'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('升级功能开发中')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                      ),
                      child: const Text('立即升级'),
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

  Widget _buildPlanCompareRow(
    String feature,
    String free,
    String basic,
    String pro, {
    bool isHeader = false,
  }) {
    final style = isHeader
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
        : const TextStyle(fontSize: 13);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(feature, style: style)),
          Expanded(child: Text(free, style: style, textAlign: TextAlign.center)),
          Expanded(child: Text(basic, style: style, textAlign: TextAlign.center)),
          Expanded(child: Text(pro, style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(featureName),
        content: const Text('此功能为专业版功能，请升级后使用'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('知道了'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showPlanCompare(context);
            },
            child: const Text('查看版本对比'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }
}
