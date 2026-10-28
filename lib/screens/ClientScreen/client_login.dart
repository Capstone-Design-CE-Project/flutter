import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:phone_hint_android/phone_hint_android.dart';

import '../../api/api_service.dart';
import '../../api/client_session.dart';
import '../../auth/auth_session.dart';
import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';
import 'client_phone_input.dart';

class ClientloginWidget extends StatefulWidget {
  const ClientloginWidget({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<ClientloginWidget> createState() => _ClientloginWidgetState();
}

class _ClientloginWidgetState extends State<ClientloginWidget> {
  final ApiService _apiService = ApiService();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isPreparingPhone = true;
  String? _phoneNumber;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preparePhoneNumber();
    });
  }

  Future<void> _preparePhoneNumber() async {
    String? phoneNumber;
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        phoneNumber = await PhoneHintAndroid().getPhoneNumber();
      } catch (_) {
        phoneNumber = null;
      }
    }

    if (!mounted) return;
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      phoneNumber = await _requestPhoneNumber();
    }
    if (!mounted) return;
    setState(() {
      _phoneNumber = phoneNumber?.trim();
      _isPreparingPhone = false;
    });
  }

  Future<String?> _requestPhoneNumber() {
    return Navigator.of(context).push<String>(
      PageRouteBuilder<String>(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ClientPhoneInputScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
      ),
    );
  }

  Future<void> _retryPhoneInput() async {
    final phoneNumber = await _requestPhoneNumber();
    if (!mounted) return;
    if (phoneNumber != null) {
      setState(() {
        _phoneNumber = phoneNumber;
        _errorMessage = null;
      });
    }
  }

  int? _clientIdFromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    final client = response['client'];
    final user = response['user'];
    final dataClient = data is Map ? data['client'] : null;
    final values = <Object?>[
      response['client_id'],
      response['user_id'],
      if (data is Map) data['client_id'],
      if (data is Map) data['user_id'],
      if (client is Map) client['client_id'] ?? client['id'],
      if (user is Map) user['client_id'] ?? user['id'],
      if (dataClient is Map) dataClient['client_id'] ?? dataClient['id'],
    ];

    for (final value in values) {
      if (value is int && value > 0) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    return null;
  }

  Future<void> _login() async {
    final phoneNumber = _phoneNumber?.trim();
    final pin = _pinController.text.trim();
    if (phoneNumber == null || phoneNumber.isEmpty) {
      setState(() => _errorMessage = '전화번호를 확인해 주세요.');
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      setState(() => _errorMessage = 'PIN 6자리를 입력해 주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    widget.authSession.signOut();

    try {
      final response = await _apiService.loginClient(
        loginId: phoneNumber,
        pin: pin,
      );
      final token = response['access_token'];
      if (token is! String || token.isEmpty) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacementNamed(PrototypeRoutes.loginFailure);
        return;
      }

      final clientId = _clientIdFromResponse(response);
      if (clientId == null) {
        throw const FormatException('로그인 응답에서 사용자 ID를 찾을 수 없습니다.');
      }

      ClientSession.start(clientId: clientId, loginId: phoneNumber);
      widget.authSession.signIn();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(PrototypeRoutes.clientHome);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      body: SafeArea(
        child: _isPreparingPhone
            ? const Center(child: CircularProgressIndicator())
            : _phoneNumber == null
            ? _buildPhoneRequired()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8EEF4),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const DeviceClock(color: Color(0xFF1A2B49)),
                              const Spacer(),
                              SvgPicture.asset(
                                'asset/images/vector3.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 6),
                              SvgPicture.asset(
                                'asset/images/vector4.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 6),
                              SvgPicture.asset(
                                'asset/images/vector5.svg',
                                width: 28,
                                height: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            '기억의 조각',
                            style: TextStyle(
                              color: Color(0xFF1A2B49),
                              fontFamily: 'GowunBatang',
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '소중한 인지 치료 여정에 오신 것을 환영합니다',
                            style: TextStyle(
                              color: Color(0xFF344B6E),
                              fontFamily: 'GowunBatang',
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A1A2B49),
                              offset: Offset(0, 8),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              '로그인',
                              style: TextStyle(
                                color: Color(0xFF1A2B49),
                                fontFamily: 'GowunBatang',
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '전화번호 ${_phoneNumber!}를 확인한 뒤 PIN 6자리를 입력해 주세요.',
                              style: TextStyle(
                                color: Color(0xFF344B6E),
                                fontFamily: 'GowunBatang',
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _pinController,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _login(),
                              decoration: const InputDecoration(
                                labelText: 'PIN 6자리',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFB42318),
                                  fontFamily: 'GowunBatang',
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: _isLoading ? null : _login,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B53),
                                foregroundColor: const Color(0xFF1A2B49),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      '접속하기',
                                      style: TextStyle(
                                        fontFamily: 'GowunBatang',
                                        fontSize: 17,
                                      ),
                                    ),
                            ),
                            TextButton(
                              onPressed: () => openPrototypeRoute(
                                context,
                                PrototypeRoutes.counselorLogin,
                              ),
                              child: const Text('상담사로 로그인하기'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPhoneRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '전화번호가 필요합니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1A2B49),
                fontFamily: 'GowunBatang',
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _retryPhoneInput,
              child: const Text('전화번호 입력하기'),
            ),
          ],
        ),
      ),
    );
  }
}
