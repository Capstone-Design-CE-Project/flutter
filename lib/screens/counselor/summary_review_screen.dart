import 'package:flutter/material.dart';
import 'image_generation_wait_screen.dart';

class SummaryReviewScreen extends StatefulWidget {
  const SummaryReviewScreen({super.key});

  @override
  State<SummaryReviewScreen> createState() => _SummaryReviewScreenState();
}

class _SummaryReviewScreenState extends State<SummaryReviewScreen> {
  final _summaryCtrl = TextEditingController(
    text: "AI가 작성한 초기 요약본입니다. 상담사가 이 내용을 첨삭하고 수정할 수 있습니다.",
  );

  void _onComplete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("저장 확인"),
        content: const Text("이대로 저장하시겠습니까?"),
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
                MaterialPageRoute(
                  builder: (_) => const ImageGenerationWaitScreen(),
                ),
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
      appBar: AppBar(title: const Text("요약 검토 및 첨삭")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _summaryCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "상담 요약을 작성하세요",
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onComplete,
              child: const Text("완료 및 이미지 생성하기"),
            ),
          ],
        ),
      ),
    );
  }
}
