import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import 'staff_form_page.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  List<Staff> _staffs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaffs();
  }

  Future<void> _loadStaffs() async {
    setState(() => _isLoading = true);
    try {
      final staffs = await StaffService().getStaffs();
      setState(() {
        _staffs = staffs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Load staffs error: $e');
      setState(() => _isLoading = false);
    }
  }

  String _getLevelText(int level) {
    switch (level) {
      case 1: return '超级管理员';
      case 2: return '管理员';
      case 3: return '操作员';
      case 4: return '查看者';
      default: return '未知';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('员工管理')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _staffs.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _loadStaffs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _staffs.length,
                    itemBuilder: (context, index) => _buildStaffCard(_staffs[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffFormPage())).then((_) => _loadStaffs()),
        backgroundColor: const Color(0xFF165DFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('暂无员工', style: TextStyle(fontSize: 16, color: Color(0xFF86909C))),
        ],
      ),
    );
  }

  Widget _buildStaffCard(Staff staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF165DFF).withValues(alpha: 0.1),
          child: Text(staff.name.isNotEmpty ? staff.name[0] : '?', style: const TextStyle(color: Color(0xFF165DFF), fontWeight: FontWeight.bold)),
        ),
        title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(staff.phone, style: const TextStyle(fontSize: 12, color: Color(0xFF86909C))),
            Text(_getLevelText(staff.level), style: const TextStyle(fontSize: 12, color: Color(0xFF86909C))),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StaffFormPage(staff: staff))).then((_) => _loadStaffs()),
      ),
    );
  }
}
