import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_page.dart';
import '../products/products_page.dart';
import '../inbound/inbound_list_page.dart';
import '../outbound/outbound_pages.dart';
import '../warehouse/warehouse_pages.dart';
import '../reports/reports_page.dart';
import '../staff/staff_pages.dart';
import '../profile/profile_page.dart';
import '../../providers/auth_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  int get _productsIndex => 1;
  int get _inboundIndex => 2;
  int get _outboundIndex => 3;
  int get _reportsIndex => 4;

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final canManageWarehouse = authProvider.canManageWarehouse;
    final canManageStaff = authProvider.canManageStaff;

    final List<Widget> _pages = [
      HomePage(
        onNavigateToInbound: () => _navigateTo(_inboundIndex),
        onNavigateToOutbound: () => _navigateTo(_outboundIndex),
        onNavigateToProducts: () => _navigateTo(_productsIndex),
        onNavigateToReports: () => _navigateTo(_reportsIndex),
      ),
      const ProductsPage(),
      const InboundListPage(),
      const OutboundListPage(),
      const ReportsPage(),
      if (canManageWarehouse) const WarehouseListPage(),
      if (canManageStaff) const StaffListPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: _buildBottomNav(canManageWarehouse, canManageStaff),
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool canManageWarehouse, bool canManageStaff) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: '首页',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2_outlined),
        activeIcon: Icon(Icons.inventory_2),
        label: '商品',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.move_to_inbox_outlined),
        activeIcon: Icon(Icons.move_to_inbox),
        label: '入库',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.output_outlined),
        activeIcon: Icon(Icons.output),
        label: '出库',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.analytics_outlined),
        activeIcon: Icon(Icons.analytics),
        label: '报表',
      ),
    ];

    if (canManageWarehouse) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.warehouse_outlined),
        activeIcon: Icon(Icons.warehouse),
        label: '仓库',
      ));
    }

    if (canManageStaff) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.people_outline),
        activeIcon: Icon(Icons.people),
        label: '职员',
      ));
    }

    items.add(const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: '我的',
    ));

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF165DFF),
      unselectedItemColor: const Color(0xFF86909C),
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 0,
      items: items,
    );
  }
}
