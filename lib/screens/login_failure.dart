import 'package:flutter/material.dart';

import '../navigation/prototype_routes.dart';

class LoginFailureScreen extends StatelessWidget {
  const LoginFailureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 72,
                  color: Color(0xFFB42318),
                ),
                const SizedBox(height: 24),
                const Text(
                  '로그인할 수 없습니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1A2B49),
                    fontFamily: 'GowunBatang',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '인증 정보를 받지 못했습니다.\n잠시 후 다시 로그인해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF526176),
                    fontFamily: 'GowunBatang',
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(PrototypeRoutes.clientLogin),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B53),
                      foregroundColor: const Color(0xFF1A2B49),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      '다시 로그인하기',
                      style: TextStyle(
                        fontFamily: 'GowunBatang',
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
