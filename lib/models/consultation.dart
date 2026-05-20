// --- [Data Model] API 통신용 데이터 구조 ---
class Consultation {
  final String id;
  final String imageUrl;
  final String date; // "2026-04-25 15:00" 형태
  final String summary; // 상담 요약문
  final int dDay; // 계산된 D-Day

  Consultation({
    required this.id,
    required this.imageUrl,
    required this.date,
    required this.summary,
    required this.dDay,
  });
}
