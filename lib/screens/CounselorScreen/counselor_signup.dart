import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../api/api_service.dart';
import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class CounselorsignupWidget extends StatefulWidget {
  const CounselorsignupWidget({super.key});

  @override
  State<CounselorsignupWidget> createState() => _CounselorsignupWidgetState();
}

class _CounselorsignupWidgetState extends State<CounselorsignupWidget> {
  final _nameController = TextEditingController();
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _organizationController = TextEditingController();
  final _apiService = ApiService();

  bool _isSaving = false;
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _loginIdController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final loginId = _loginIdController.text.trim();
    final password = _passwordController.text;
    if (name.isEmpty) {
      _showMessage('이름을 입력해 주세요.');
      return;
    }
    if (loginId.isEmpty) {
      _showMessage('아이디를 입력해 주세요.');
      return;
    }
    if (password.length < 8) {
      _showMessage('비밀번호는 8자리 이상 입력해 주세요.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _apiService.createCounselor(
        loginId: loginId,
        password: password,
        name: name,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        organization: _organizationController.text.trim().isEmpty
            ? null
            : _organizationController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed(PrototypeRoutes.counselorLogin);
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _decoration({required String hintText, Widget? suffixIcon}) {
    const borderColor = Color(0xFFEAEFF2);
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF7D879C),
        fontSize: 15,
        fontFamily: 'GowunBatang',
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderSide: const BorderSide(width: 1.5, color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 1.5, color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(width: 1.5, color: Color(0xFFFF6B53)),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A2B49),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: !_isSaving,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: const TextStyle(color: Color(0xFF1A2B49), fontSize: 15),
          decoration: _decoration(hintText: hintText, suffixIcon: suffixIcon),
        ),
      ],
    );
  }

  Widget _topBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        children: [
          const DeviceClock(color: Color(0xFF1A2B49), fontSize: 15),
          const Spacer(),
          SvgPicture.asset('asset/images/vector3.svg', width: 20, height: 20),
          const SizedBox(width: 6),
          SvgPicture.asset('asset/images/vector4.svg', width: 20, height: 20),
          const SizedBox(width: 6),
          SvgPicture.asset('asset/images/vector5.svg', width: 28, height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'GowunBatang'),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(fontFamily: 'GowunBatang'),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F5),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 402),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _topBar(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _isSaving
                                ? null
                                : () => Navigator.of(context).maybePop(),
                            tooltip: '뒤로가기',
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF1A2B49),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '상담사 계정 생성',
                            style: TextStyle(
                              color: Color(0xFF1A2B49),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0x14FF6B53),
                        border: Border.all(color: const Color(0x26FF6B53)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '상담사로 사용할 계정 정보를 입력해 주세요.',
                        style: TextStyle(
                          color: Color(0xFF7D879C),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _field(
                            label: '이름',
                            controller: _nameController,
                            hintText: '이름을 입력하세요',
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          _field(
                            label: 'ID',
                            controller: _loginIdController,
                            hintText: '사용할 아이디를 입력하세요',
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          _field(
                            label: '비밀번호',
                            controller: _passwordController,
                            hintText: '영문/숫자 포함 8자리 이상',
                            obscureText: _isPasswordObscured,
                            textInputAction: TextInputAction.next,
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () =>
                                    _isPasswordObscured = !_isPasswordObscured,
                              ),
                              tooltip: _isPasswordObscured
                                  ? '비밀번호 표시'
                                  : '비밀번호 숨기기',
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF7D879C),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _field(
                            label: '전화번호',
                            controller: _phoneController,
                            hintText: '010-0000-0000',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          _field(
                            label: 'Email',
                            controller: _emailController,
                            hintText: 'abcd1234@naver.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          _field(
                            label: '소속',
                            controller: _organizationController,
                            hintText: '기관/단체/기업명 기입',
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B53),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xFFFFB8AB,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      '저장하기',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
