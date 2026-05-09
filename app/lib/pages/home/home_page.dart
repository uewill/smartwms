import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../products/products_page.dart';
import '../inbound/inbound_list_page.dart';
import '../outbound/outbound_pages.dart';
import '../reports/reports_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToInbound;
  final VoidCallback? onNavigateToOutbound;
  final VoidCallback? onNavigateToProducts;
  final VoidCallback? onNavigateToReports;

  const HomePage({
    super.key,
    this.onNavigateToInbound,
    this.onNavigateToOutbound,
    this.onNavigateToProducts,
    this.onNavigateToReports,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await ReportService().getDashboard();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Load dashboard error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 180,
                    floating: false,
                    pinned: true,
                    backgroundColor: const Color(0xFF165DFF),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF165DFF), Color(0xFF722ED1)],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  'SmartWMS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _dashboardData?['welcome'] ?? '欢迎使用智能仓储管理系统',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('数据概览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildStatCard('商品总数', '${_dashboardData?['totalProducts'] ?? 0}', Icons.inventory_2, const Color(0xFF165DFF))),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatCard('入库订单', '${_dashboardData?['totalInbound'] ?? 0}', Icons.move_to_inbox, const Color(0xFF00B42A))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildStatCard('出库订单', '${_dashboardData?['totalOutbound'] ?? 0}', Icons.local_shipping, const Color(0xFFFF7D00))),
                              const SizedBox(width: 16),
                              Expanded(child: _buildStatCard('总库存', '${_dashboardData?['totalStock'] ?? 0}', Icons.warehouse, const Color(0xFF722ED1))),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text('快捷操作', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _buildQuickActions(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Color(0xFF86909C), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildActionItem(Icons.add_box, '入库', const Color(0xFF00B42A), () => widget.onNavigateToInbound?.call()),
        _buildActionItem(Icons.output, '出库', const Color(0xFFFF7D00), () => widget.onNavigateToOutbound?.call()),
        _buildActionItem(Icons.inventory, '库存', const Color(0xFF165DFF), () => widget.onNavigateToProducts?.call()),
        _buildActionItem(Icons.assessment, '报表', const Color(0xFF722ED1), () => widget.onNavigateToReports?.call()),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
