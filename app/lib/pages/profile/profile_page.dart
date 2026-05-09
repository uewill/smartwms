import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  List<OperationLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userResponse = await AuthService().getUserInfo();
      final logs = await AuthService().getOperationLogs();
      setState(() {
        if (userResponse.isSuccess && userResponse.data != null) {
          _user = userResponse.data!.user;
        }
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Load profile error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildUserCard(),
                const SizedBox(height: 24),
                _buildSection('操作日志', _logs.isEmpty
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('暂无操作记录', style: TextStyle(color: Color(0xFF86909C))),
                      ))
                    : Column(
                        children: _logs.take(10).map((log) => _buildLogItem(log)).toList(),
                      )),
              ],
            ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF165DFF), Color(0xFF722ED1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              _user?.nickname.isNotEmpty == true ? _user!.nickname[0] : '?',
              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_user?.nickname ?? '未登录', style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_user?.phone ?? '', style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _buildLogItem(OperationLog log) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF2F3F5))),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Color(0xFF165DFF), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.action, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('${log.type} - ${log.action}', style: const TextStyle(fontSize: 12, color: Color(0xFF86909C))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
