/// 백엔드의 Session 및 Album 테이블 구조와 매핑되는 메인 모델
class ConsultationSession {
  final int sessionId;
  final int userId;
  final String createdAt;
  final String? summary; // promptmaker를 통해 요약되거나 생성된 텍스트
  final List<AlbumImage> albums; // 1:N 관계를 고려한 이미지 리스트

  ConsultationSession({
    required this.sessionId,
    required this.userId,
    required this.createdAt,
    this.summary,
    required this.albums,
  });

  /// 세션 상세 조회 등이 있을 경우를 대비한 팩토리 메서드
  factory ConsultationSession.fromJson(Map<String, dynamic> json) {
    var albumList = json['albums'] as List? ?? [];
    List<AlbumImage> albumObjects =
        albumList.map((i) => AlbumImage.fromJson(i)).toList();

    return ConsultationSession(
      sessionId: json['session_id'] ?? json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      summary: json['summary'],
      albums: albumObjects,
    );
  }

  /// 계산된 D-Day를 반환하는 Getter
  int get dDay {
    if (createdAt.isEmpty) return 0;
    try {
      DateTime parsedDate = DateTime.parse(createdAt);
      DateTime now = DateTime.now();
      // 날짜 단위 계산을 위해 시간 제거
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime targetDate =
          DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

      return today.difference(targetDate).inDays;
    } catch (_) {
      return 0;
    }
  }
}

/// 백엔드 album 테이블 구조와 매핑되는 서브 모델
class AlbumImage {
  final int id;
  final int sessionId;
  final String imageUrl; // DALL-E를 통해 생성되어 저장된 S3 혹은 로컬 URL
  final String createdAt;

  AlbumImage({
    required this.id,
    required this.sessionId,
    required this.imageUrl,
    required this.createdAt,
  });

  factory AlbumImage.fromJson(Map<String, dynamic> json) {
    return AlbumImage(
      id: json['id'] ?? 0,
      sessionId: json['session_id'] ?? 0,
      imageUrl: json['image_url'] ?? json['url'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}