import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import 'inbound_form_page.dart';
import 'inbound_detail_page.dart';

class InboundListPage extends StatefulWidget {
  const InboundListPage({super.key});

  @override
  State<InboundListPage> createState() => _InboundListPageState();
}

class _InboundListPageState extends State<InboundListPage> {
  List<InboundOrder> _orders = [];
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
      final orders = await InboundService().getOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Load inbound orders error: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return '待审核';
      case 'approved': return '已审核';
      case 'completed': return '已完成';
      case 'cancelled': return '已取消';
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFFF7D00);
      case 'approved': return const Color(0xFF165DFF);
      case 'completed': return const Color(0xFF00B42A);
      case 'cancelled': return const Color(0xFF86909C);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('入库单'),
      ),
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
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InboundFormPage())).then((_) => _loadOrders()),
        backgroundColor: const Color(0xFF00B42A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.move_to_inbox_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('暂无入库单', style: TextStyle(fontSize: 16, color: Color(0xFF86909C))),
        ],
      ),
    );
  }

  Widget _buildOrderCard(InboundOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InboundDetailPage(orderId: order.id))).then((_) => _loadOrders()),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.orderNo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(_getStatusText(order.status), style: TextStyle(fontSize: 12, color: _getStatusColor(order.status))),
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
                  const Icon(Icons.business_outlined, size: 16, color: Color(0xFF86909C)),
                  const SizedBox(width: 4),
                  Text(order.supplier, style: const TextStyle(fontSize: 14, color: Color(0xFF4E5969))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${order.totalQuantity} 件', style: const TextStyle(fontSize: 14, color: Color(0xFF4E5969))),
                  Text('¥${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF165DFF))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
