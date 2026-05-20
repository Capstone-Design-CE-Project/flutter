import 'package:flutter/material.dart';
import '../../config/app_settings.dart';
import '../../config/constants.dart';
import 'client_list_screen.dart';
import 'calendar_screen.dart';
import 'consultation_start_screen.dart';

class CounselorMain extends StatelessWidget {
  const CounselorMain({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.consultationSystem),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              "상담사 ㅇㅇㅇ님으로 로그인하셨습니다",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientListScreen()),
              ),
              child: const Text(AppTexts.clientList),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              ),
              child: const Text(AppTexts.calendar),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ConsultationStartScreen(),
                ),
              ),
              child: const Text(AppTexts.newConsultation),
            ),
          ],
        ),
      ),
    );
  }
}
