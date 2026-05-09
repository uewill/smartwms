import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class StaffFormPage extends StatefulWidget {
  final Staff? staff;
  const StaffFormPage({super.key, this.staff});

  @override
  State<StaffFormPage> createState() => _StaffFormPageState();
}

class _StaffFormPageState extends State<StaffFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _remarkController = TextEditingController();
  int _level = 3;
  String _status = 'active';
  bool _isLoading = false;

  bool get _isEdit => widget.staff != null;

  @override
  void initState() {
    super.initState();
    if (widget.staff != null) {
      _nameController.text = widget.staff!.name;
      _phoneController.text = widget.staff!.phone;
      _emailController.text = widget.staff!.email ?? '';
      _remarkController.text = widget.staff!.remark ?? '';
      _level = widget.staff!.level;
      _status = widget.staff!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  String _getLevelName(int level) {
    switch (level) {
      case 1: return '超级管理员';
      case 2: return '管理员';
      case 3: return '操作员';
      case 4: return '查看者';
      default: return '未知';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success;
      if (_isEdit) {
        success = await StaffService().updateStaff(
          id: widget.staff!.id,
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          level: _level,
          status: _status,
          remark: _remarkController.text.isNotEmpty ? _remarkController.text : null,
        );
      } else {
        success = await StaffService().createStaff(
          name: _nameController.text,
          phone: _phoneController.text,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          level: _level,
          remark: _remarkController.text.isNotEmpty ? _remarkController.text : null,
        );
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_isEdit ? '修改成功' : '创建成功')),
          );
          Navigator.pop(context);
        }
      } else {
        _showError('操作失败');
      }
    } catch (e) {
      _showError('操作失败');
    }

    setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),
      appBar: AppBar(
        title: Text(_isEdit ? '编辑员工' : '新建员工'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('基本信息', [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '姓名 *',
                  hintText: '请输入员工姓名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入员工姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '手机号 *',
                  hintText: '请输入手机号',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入手机号';
                  }
                  if (value.length != 11) {
                    return '请输入正确的手机号';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  hintText: '请输入邮箱（选填）',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('权限设置', [
              const Text('角色权限', style: TextStyle(color: Color(0xFF86909C), fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [1, 2, 3, 4].map((level) {
                  final isSelected = _level == level;
                  return GestureDetector(
                    onTap: () => setState(() => _level = level),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF165DFF).withValues(alpha: 0.1) : Colors.grey[100],
                        border: Border.all(
                          color: isSelected ? const Color(0xFF165DFF) : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getLevelName(level),
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF165DFF) : Colors.grey[600],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                _getLevelDescription(_level),
                style: const TextStyle(color: Color(0xFF86909C), fontSize: 12),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('状态设置', [
              Row(
                children: [
                  Expanded(child: _buildStatusOption('active', '正常')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatusOption('inactive', '停用')),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('备注', [
              TextFormField(
                controller: _remarkController,
                decoration: const InputDecoration(
                  labelText: '备注信息',
                  hintText: '请输入备注（选填）',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF165DFF),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isEdit ? '保存修改' : '创建员工'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatusOption(String value, String label) {
    final isSelected = _status == value;
    return GestureDetector(
      onTap: () => setState(() => _status = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF165DFF).withValues(alpha: 0.1) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? const Color(0xFF165DFF) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF165DFF) : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  String _getLevelDescription(int level) {
    switch (level) {
      case 1: return '拥有系统所有权限，可管理所有租户数据';
      case 2: return '可管理仓库、商品、入出库等日常运营';
      case 3: return '可进行入出库操作，查看报表';
      case 4: return '仅可查看数据，无操作权限';
      default: return '';
    }
  }
}
