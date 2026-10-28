import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../auth/auth_session.dart';
import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class CounselorLoginV3 extends StatefulWidget {
  const CounselorLoginV3({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<CounselorLoginV3> createState() => _CounselorLoginV3State();
}

class _CounselorLoginV3State extends State<CounselorLoginV3> {
  final ApiService _apiService = ApiService();
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showLoginError = false;

  Future<void> _login() async {
    if (_isLoading) return;
    final loginId = _loginIdController.text.trim();
    final password = _passwordController.text;

    if (loginId.isEmpty || password.isEmpty) {
      setState(() => _showLoginError = true);
      return;
    }

    setState(() {
      _isLoading = true;
      _showLoginError = false;
    });
    _apiService.clearAuthToken();
    widget.authSession.signOut();

    try {
      final response = await _apiService.loginCounselor(
        loginId: loginId,
        password: password,
      );
      final token = response['access_token'];
      if (token is! String || token.isEmpty) {
        _showFailure();
        return;
      }
      widget.authSession.signIn();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(PrototypeRoutes.dashboard);
    } catch (_) {
      _showFailure();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFailure() {
    if (!mounted) return;
    setState(() => _showLoginError = true);
  }

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1A2B49);
    const accent = Color(0xFFFF6B53);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 402),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [accent, Color(0xFFFF8E7C)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DeviceClock(color: Colors.white),
                        const SizedBox(height: 32),

                        const SizedBox(height: 16),
                        Text(
                          '기억의 조각',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontFamily: 'GowunBatang',
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '상담사 전용 로그인 시스템',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'GowunBatang',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '상담사 로그인',
                            style: TextStyle(
                              color: navy,
                              fontFamily: 'GowunBatang',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _loginIdController,
                            enabled: !_isLoading,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) {
                              if (_showLoginError) {
                                setState(() => _showLoginError = false);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: '상담사 아이디 (ID)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            enabled: !_isLoading,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _login(),
                            onChanged: (_) {
                              if (_showLoginError) {
                                setState(() => _showLoginError = false);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: '비밀번호',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? '비밀번호 표시'
                                    : '비밀번호 숨기기',
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          if (_showLoginError) ...[
                            const SizedBox(height: 12),
                            const Text(
                              '아이디나 비밀번호를 다시 확인하세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFB42318),
                                fontFamily: 'GowunBatang',
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _isLoading ? null : _login,
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '로그인',
                                    style: TextStyle(
                                      fontFamily: 'GowunBatang',
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => openPrototypeRoute(
                                    context,
                                    PrototypeRoutes.entry,
                                    transition: FlowTransition.slideBack,
                                  ),
                            child: const Text('메인 화면으로 돌아가기'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
