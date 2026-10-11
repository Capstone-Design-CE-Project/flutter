import 'package:flutter/material.dart';

import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class ClientPhoneInputScreen extends StatefulWidget {
  const ClientPhoneInputScreen({super.key});

  @override
  State<ClientPhoneInputScreen> createState() => _ClientPhoneInputScreenState();
}

class _ClientPhoneInputScreenState extends State<ClientPhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorMessage;

  void _continue() {
    final phone = _phoneController.text.trim();
    final digitCount = phone.replaceAll(RegExp(r'\D'), '').length;
    if (digitCount < 10 || digitCount > 15) {
      setState(() => _errorMessage = '전화번호를 다시 확인해 주세요.');
      return;
    }
    Navigator.of(context).pop(phone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          PrototypeRoutes.entry,
                          (route) => false,
                        ),
                    icon: const Icon(Icons.home_outlined, size: 18),
                    label: const Text('메인 화면'),
                  ),
                  const Spacer(),
                  const DeviceClock(color: Color(0xFF1A2B49)),
                ],
              ),
              const SizedBox(height: 48),
              const Text(
                '전화번호 입력',
                style: TextStyle(
                  color: Color(0xFF1A2B49),
                  fontFamily: 'GowunBatang',
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '이 휴대전화에 등록된 번호를 불러오지 못했습니다. 가입할 때 사용한 전화번호를 입력해 주세요.',
                style: TextStyle(
                  color: Color(0xFF344B6E),
                  fontFamily: 'GowunBatang',
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _phoneController,
                autofocus: true,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumber],
                onSubmitted: (_) => _continue(),
                decoration: const InputDecoration(
                  labelText: '휴대전화 번호',
                  hintText: '010-1234-5678',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
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
                onPressed: _continue,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B53),
                  foregroundColor: const Color(0xFF1A2B49),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  '계속하기',
                  style: TextStyle(fontFamily: 'GowunBatang', fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
