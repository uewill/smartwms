import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import 'outbound_form_page.dart';

class OutboundListPage extends StatefulWidget {
  const OutboundListPage({super.key});

  @override
  State<OutboundListPage> createState() => _OutboundListPageState();
}

class _OutboundListPageState extends State<OutboundListPage> {
  List<OutboundOrder> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final orders = await OutboundService().getOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Load orders error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('出库单')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) => _buildOrderCard(_orders[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OutboundFormPage())).then((_) => _loadOrders()),
        backgroundColor: const Color(0xFFFF7D00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('暂无出库单', style: TextStyle(fontSize: 16, color: Color(0xFF86909C))),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OutboundOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderNo, style: const TextStyle(fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7D00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(order.status, style: const TextStyle(fontSize: 12, color: Color(0xFFFF7D00))),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF86909C)),
                const SizedBox(width: 4),
                Text(order.warehouseName, style: const TextStyle(fontSize: 14, color: Color(0xFF4E5969))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Color(0xFF86909C)),
                const SizedBox(width: 4),
                Text(order.customer, style: const TextStyle(fontSize: 14, color: Color(0xFF4E5969))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${order.totalQuantity} 件', style: const TextStyle(fontSize: 14, color: Color(0xFF4E5969))),
                Text('¥${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF7D00))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
