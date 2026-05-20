import 'package:flutter/material.dart';
import 'image_review_screen.dart';

class ImageGenerationWaitScreen extends StatefulWidget {
  const ImageGenerationWaitScreen({super.key});

  @override
  State<ImageGenerationWaitScreen> createState() =>
      _ImageGenerationWaitScreenState();
}

class _ImageGenerationWaitScreenState extends State<ImageGenerationWaitScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ImageReviewScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("AI가 상담 이미지를 생성 중입니다...",
                style: TextStyle(fontSize: 18)),
            Text("잠시만 기다려주세요.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
