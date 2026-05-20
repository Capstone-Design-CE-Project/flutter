import 'package:flutter/material.dart';
import 'consultation_complete_screen.dart';

class ImageReviewScreen extends StatelessWidget {
  const ImageReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("생성된 이미지 검토")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.blue[100],
              alignment: Alignment.center,
              child: const Text(
                "생성된 이미지",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("다시 생성"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConsultationCompleteScreen(),
                        ),
                      );
                    },
                    child: const Text("확인"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
