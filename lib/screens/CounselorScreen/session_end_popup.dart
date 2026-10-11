import 'package:flutter/material.dart';

import '../../navigation/prototype_routes.dart';
import 'session_flow_payloads.dart';

void main() {
  runApp(const MaterialApp(home: SessionEndPopupV3()));
}

class SessionEndPopupV3 extends StatelessWidget {
  const SessionEndPopupV3({super.key, this.request});

  final SessionEndConfirmationRequest? request;

  @override
  Widget build(BuildContext context) {
    final isRecordingConfirmation =
        request?.mode == SessionEndConfirmationMode.recording;
    final name = request?.clientName.trim();
    final message = isRecordingConfirmation
        ? name?.isNotEmpty == true
              ? '$name님의 녹음을 종료하고 요약 생성을 시작하시겠습니까?'
              : '녹음을 종료하고 요약 생성을 시작하시겠습니까?'
        : name?.isNotEmpty == true
        ? '$name님의 상담을 완료하고 대시보드로 이동하시겠습니까?'
        : '상담을 완료하고 대시보드로 이동하시겠습니까?';

    return Scaffold(
      backgroundColor: const Color(0x72111827),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A111827),
                      blurRadius: 32,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0EEFC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.stop_circle_outlined,
                        color: Color(0xFF514C87),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isRecordingConfirmation ? '녹음 종료 확인' : '상담 완료 확인',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1A2B49),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF7D879C),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          if (isRecordingConfirmation) {
                            Navigator.of(context).pop(true);
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              PrototypeRoutes.dashboard,
                              (route) => false,
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B53),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isRecordingConfirmation
                              ? '예, 요약 생성으로 이동'
                              : '네, 시작합니다',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(
                          isRecordingConfirmation ? false : null,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A2B49),
                          side: const BorderSide(
                            color: Color(0xFF1A2B49),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isRecordingConfirmation
                              ? '아니요, 녹음 계속하기'
                              : '아니요, 돌아가기',
                        ),
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
