import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_settings.dart';
import '../../models/consultation.dart';
import 'senior_session_screen.dart';

class SeniorAlbumScreen extends StatelessWidget {
  const SeniorAlbumScreen({super.key});

  Future<List<Consultation>> _fetchAlbumData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.generate(
      10,
      (index) => Consultation(
        id: "id_$index",
        imageUrl: "https://picsum.photos/400/400?random=${index}",
        date: "2026년 4월 ${index + 1}일",
        summary: "상담 결과 $index: 어르신께서 $index번째 상담에서 매우 긍정적인 반응을 보이셨습니다.",
        dDay: 0,
      ),
    );
  }

  void _showSessionDetail(BuildContext context, Consultation session, double scale) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(session.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "상담 세션",
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.date.replaceAll('\n', ' '),
                      style: TextStyle(
                        fontSize: 14 * scale,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        session.summary,
                        style: TextStyle(
                          fontSize: 16 * scale,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                        label: Text(
                          "닫기",
                          style: TextStyle(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF001B3B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final settings = SettingsProvider.of(context);
    final scale = settings.fontSizeMultiplier;

    return FutureBuilder<List<Consultation>>(
      future: _fetchAlbumData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final sessions = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: 6, // Show 6 items as in the mockup
          itemBuilder: (context, index) {
            final session = sessions[index];
            return GestureDetector(
              onTap: () {
                if (settings.isHapticEnabled) HapticFeedback.lightImpact();
                _showSessionDetail(context, session, scale);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                  image: DecorationImage(
                    image: NetworkImage(session.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
