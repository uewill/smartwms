import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';

class InboundDetailPage extends StatefulWidget {
  final String orderId;
  const InboundDetailPage({super.key, required this.orderId});

  @override
  State<InboundDetailPage> createState() => _InboundDetailPageState();
}

class _InboundDetailPageState extends State<InboundDetailPage> {
  InboundOrder? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    try {
      final order = await InboundService().getOrder(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
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
      backgroundColor: const Color(0xFFF1F2F6),
      appBar: AppBar(
        title: const Text('入库单详情'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('未找到订单'))
              : RefreshIndicator(
                  onRefresh: _loadOrder,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildInfoCard(),
                      const SizedBox(height: 16),
                      _buildItemsCard(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B42A), Color(0xFF00C597)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('入库单号', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(_order!.orderNo, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(_order!.status),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat('商品种类', '${_order!.items.length}'),
              _buildHeaderStat('总数量', '${_order!.totalQuantity}'),
              _buildHeaderStat('总金额', '¥${_order!.totalAmount.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('基本信息', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.warehouse, '仓库', _order!.warehouseName),
          _buildInfoRow(Icons.business, '供应商', _order!.supplier),
          _buildInfoRow(Icons.calendar_today, '创建时间', _formatDate(_order!.createdAt)),
          if (_order!.remark != null && _order!.remark!.isNotEmpty)
            _buildInfoRow(Icons.note, '备注', _order!.remark!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF86909C)),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(color: Color(0xFF86909C))),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('入库商品', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ..._order!.items.map((item) => _buildItemRow(item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(InboundOrderItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF2F3F5))),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF00B42A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2, color: Color(0xFF00B42A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('${item.productCode ?? ''} | ¥${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF86909C))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('x${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('¥${item.amount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00B42A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_order!.status == 'completed' || _order!.status == 'cancelled') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (_order!.status == 'pending')
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B42A)),
              onPressed: () => _updateStatus('approved'),
              child: const Text('审核通过'),
            ),
          ),
        if (_order!.status == 'approved') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C597)),
              onPressed: () => _updateStatus('completed'),
              child: const Text('确认入库'),
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => _updateStatus('cancelled'),
            child: const Text('取消订单'),
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(String status) async {
    try {
      final success = await InboundService().updateStatus(widget.orderId, status);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_getStatusText(status) + '成功')),
          );
          _loadOrder();
        }
      } else {
        _showError('操作失败');
      }
    } catch (e) {
      _showError('操作失败');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
