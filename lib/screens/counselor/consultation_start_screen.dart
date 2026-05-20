import 'package:flutter/material.dart';
import 'recording_screen.dart';

class ConsultationStartScreen extends StatefulWidget {
  const ConsultationStartScreen({super.key});

  @override
  State<ConsultationStartScreen> createState() =>
      _ConsultationStartScreenState();
}

class _ConsultationStartScreenState extends State<ConsultationStartScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = "여성";

  void _onStartPressed() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("세션 시작 확인"),
        content: Text("${_nameCtrl.text}님의 <오늘 날짜> 세션을 시작하겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("아니오"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RecordingScreen()),
              );
            },
            child: const Text("예"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("상담 정보 입력")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "이름"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "나이"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _gender,
              items: ["여성", "남성"]
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v!),
              decoration: const InputDecoration(labelText: "성별"),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _onStartPressed,
              child: const Text("상담 시작하기"),
            ),
          ],
        ),
      ),
    );
  }
}
