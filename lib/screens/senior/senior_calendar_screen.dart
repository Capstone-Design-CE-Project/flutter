import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_settings.dart';

class SeniorCalendarScreen extends StatefulWidget {
  const SeniorCalendarScreen({super.key});

  @override
  State<SeniorCalendarScreen> createState() => _SeniorCalendarScreenState();
}

class _SeniorCalendarScreenState extends State<SeniorCalendarScreen> {
  bool _isAlarmEnabled = true;

  @override
  Widget build(BuildContext context) {
    final scale = SettingsProvider.of(context).fontSizeMultiplier;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Text(
            "D - 3",
            style: TextStyle(
              fontSize: 80 * scale,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(thickness: 2),
          const SizedBox(height: 30),
          Text("상담일", style: TextStyle(fontSize: 22 * scale)),
          Text(
            "2026년 4월 21일",
            style: TextStyle(fontSize: 34 * scale, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text("상담 시간", style: TextStyle(fontSize: 22 * scale)),
          Text(
            "오후 2시 30분",
            style: TextStyle(fontSize: 34 * scale, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: CheckboxListTile(
              title: Text(
                "당일 아침에 알람을 받습니다",
                style: TextStyle(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: _isAlarmEnabled,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (val) {
                if (SettingsProvider.of(context).isHapticEnabled) {
                  HapticFeedback.lightImpact();
                }
                setState(() => _isAlarmEnabled = val!);
              },
            ),
          ),
        ],
      ),
    );
  }
}
