import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clothing_erp/config/theme.dart';
import 'package:clothing_erp/providers/sale_provider.dart';
import 'package:clothing_erp/providers/subscription_provider.dart';
import 'package:clothing_erp/utils/formatter.dart';
import 'package:clothing_erp/utils/constants.dart';
import 'package:clothing_erp/routes/app_routes.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  void initState() {
    super.initState();
    context.read<SaleProvider>().loadTodaySummary();
    context.read<SubscriptionProvider>().loadSubscription();
  }

  @override
  Widget build(BuildContext context) {
    final saleProvider = context.watch<SaleProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final summary = saleProvider.todaySummary;
    final isFree = subscriptionProvider.isFree;

    return Scaffold(
      appBar: AppBar(
        title: const Text('报表'),
      ),
      body: ListView(
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ReportCard(
                          title: '销售额',
                          value: '¥${FormatterUtil.formatAmount(summary?.totalSales ?? 0)}',
                          icon: Icons.attach_money,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ReportCard(
                          title: '毛利',
                          value: '¥${FormatterUtil.formatAmount(summary?.totalProfit ?? 0)}',
                          icon: Icons.trending_up,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ReportCard(
                          title: '订单数',
                          value: '${summary?.orderCount ?? 0}',
                          icon: Icons.receipt,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ReportCard(
                          title: '客单价',
                          value: summary?.orderCount != null && summary!.orderCount! > 0
                              ? '¥${FormatterUtil.formatAmount(summary.totalSales! / summary.orderCount!)}'
                              : '¥0.00',
                          icon: Icons.person,
                          color: const Color(0xFF7B1FA2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '高级报表',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _AdvancedReportItem(
            icon: Icons.local_fire_department,
            title: '热卖排行',
            subtitle: '查看商品销量排行',
            color: Colors.red,
            isLocked: isFree,
            onTap: () => _handleAdvancedFeature(context, FeatureKeys.hotRanking, '热卖排行'),
          ),
          _AdvancedReportItem(
            icon: Icons.inventory,
            title: '积压预警',
            subtitle: '查看滞销商品',
            color: Colors.orange,
            isLocked: isFree,
            onTap: () => _handleAdvancedFeature(context, FeatureKeys.overstockWarning, '积压预警'),
          ),
          _AdvancedReportItem(
            icon: Icons.account_balance_wallet,
            title: '客户欠款',
            subtitle: '查看欠款统计',
            color: Colors.blue,
            isLocked: isFree,
            onTap: () => _handleAdvancedFeature(context, FeatureKeys.customerDebt, '客户欠款'),
          ),
          _AdvancedReportItem(
            icon: Icons.analytics,
            title: '利润分析',
            subtitle: '查看利润趋势',
            color: Colors.green,
            isLocked: isFree,
            onTap: () => _handleAdvancedFeature(context, FeatureKeys.profitAnalysis, '利润分析'),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.accentColor.withOpacity(0.05),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: AppTheme.accentColor, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '升级专业版',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.accentColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isFree
                                ? '解锁全部高级报表功能'
                                : '感谢您使用${PlanType.getLabel(subscriptionProvider.subscription?.planType ?? 'free')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.accentColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAdvancedFeature(BuildContext context, String featureKey, String featureName) async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    final enabled = await subscriptionProvider.checkFeature(featureKey);

    if (!mounted) return;

    if (enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$featureName 功能开发中')),
      );
    } else {
      _showUpgradeDialog(context, featureName);
    }
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
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            child: const Text('去升级'),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportCard({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvancedReportItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLocked;
  final VoidCallback onTap;

  const _AdvancedReportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Row(
          children: [
            Text(title),
            if (isLocked) ...[
              const SizedBox(width: 6),
              const Icon(Icons.lock, size: 14, color: AppTheme.textHintColor),
            ],
          ],
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
