import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isCodeLogin = true;
  bool _isLoading = false;
  bool _countingDown = false;
  int _countdown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_phoneController.text.length != 11) {
      _showError('请输入正确的手机号');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService().sendCode(_phoneController.text);
      if (response.isSuccess) {
        _startCountdown();
        _showSuccess('验证码已发送');
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('发送失败');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _startCountdown() {
    setState(() {
      _countingDown = true;
      _countdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _countdown--;
        });
      }
      return _countdown > 0;
    }).then((_) {
      if (mounted) {
        setState(() {
          _countingDown = false;
        });
      }
    });
  }

  Future<void> _login() async {
    if (_phoneController.text.length != 11) {
      _showError('请输入正确的手机号');
      return;
    }

    if (_isCodeLogin && _codeController.text.length != 4) {
      _showError('请输入4位验证码');
      return;
    }

    if (!_isCodeLogin && _passwordController.text.isEmpty) {
      _showError('请输入密码');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    bool success;

    if (_isCodeLogin) {
      success = await authProvider.loginByCode(_phoneController.text, _codeController.text);
    } else {
      success = await authProvider.loginByPassword(_phoneController.text, _passwordController.text);
    }

    setState(() {
      _isLoading = false;
    });

    if (!success && mounted) {
      _showError('登录失败，请检查手机号和验证码');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF53F3F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00B42A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF165DFF), Color(0xFF4080FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF165DFF).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.inventory_2, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'SmartWMS',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2129),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  '仓库出入库管理系统',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF86909C),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCodeLogin = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _isCodeLogin ? const Color(0xFF165DFF) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '验证码登录',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _isCodeLogin ? FontWeight.w600 : FontWeight.normal,
                              color: _isCodeLogin ? const Color(0xFF165DFF) : const Color(0xFF86909C),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCodeLogin = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: !_isCodeLogin ? const Color(0xFF165DFF) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '密码登录',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: !_isCodeLogin ? FontWeight.w600 : FontWeight.normal,
                              color: !_isCodeLogin ? const Color(0xFF165DFF) : const Color(0xFF86909C),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _phoneController,
                      hint: '请输入手机号',
                      prefix: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                    ),
                    if (_isCodeLogin)
                      _buildInputField(
                        controller: _codeController,
                        hint: '请输入验证码',
                        prefix: Icons.lock_outline,
                        suffix: GestureDetector(
                          onTap: _countingDown ? null : _sendCode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              _countingDown ? '${_countdown}s' : '获取验证码',
                              style: TextStyle(
                                color: _countingDown ? const Color(0xFF86909C) : const Color(0xFF165DFF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      )
                    else
                      _buildInputField(
                        controller: _passwordController,
                        hint: '请输入密码',
                        prefix: Icons.lock,
                        obscureText: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF165DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '登录',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wechat, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      // TODO: 微信登录
                      _showSuccess('微信登录开发中');
                    },
                    child: const Text(
                      '微信一键登录',
                      style: TextStyle(
                        color: Color(0xFF165DFF),
                        fontSize: 14,
                      ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefix,
    Widget? suffix,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC9CDD4)),
        prefixIcon: Icon(prefix, color: const Color(0xFF86909C)),
        suffixIcon: suffix,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
