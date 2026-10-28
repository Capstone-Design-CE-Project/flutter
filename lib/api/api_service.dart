import 'package:dio/dio.dart';
import 'consultation_model.dart';

class ApiService {
  /// 서버 주소. 빌드할 때 --dart-define 으로 바꿀 수 있다.
  ///
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   (Android 에뮬레이터)
  ///   flutter run --dart-define=API_BASE_URL=http://localhost:8000  (iOS 시뮬레이터)
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.0.5:8000 (실제 기기)
  ///
  /// 아무것도 주지 않으면 아래 운영 서버 주소를 쓴다.
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://3.36.70.79:8000',
  );

  ApiService({String? baseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl ?? defaultBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(minutes: 5),
              headers: {'Content-Type': 'application/json'},
            ),
          ) {
    final token = _sharedToken;
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  final Dio _dio;

  // ??? ??? ?? ApiService ????? ????.
  static String? _sharedToken;

  void setAuthToken(String token) {
    _sharedToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _sharedToken = null;
    _dio.options.headers.remove('Authorization');
  }

  String resolveUrl(String path) {
    final uri = Uri.parse(path);
    if (uri.hasScheme) return path;
    return Uri.parse(_dio.options.baseUrl).resolve(path).toString();
  }

  String _safeFileName(String filePath) {
    return filePath.replaceAll('\\', '/').split('/').last;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  List<T> _parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (value is List) {
      return value.map((e) => parser(_asMap(e))).whereType<T>().toList();
    }
    if (value is Map && value['items'] is List) {
      return (value['items'] as List)
          .map((e) => parser(_asMap(e)))
          .whereType<T>()
          .toList();
    }
    return <T>[];
  }

  Future<Response<dynamic>> _get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> _post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    FormData? formData,
  }) {
    return _dio.post(
      path,
      queryParameters: queryParameters,
      data: formData ?? data,
    );
  }

  Future<Response<dynamic>> _patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
  }) {
    return _dio.patch(path, queryParameters: queryParameters, data: data);
  }

  Map<String, dynamic> _saveToken(Map<String, dynamic> body) {
    final token = body['access_token'];
    if (token is String && token.isNotEmpty) setAuthToken(token);
    return body;
  }

  Future<Map<String, dynamic>> loginCounselor({
    required String loginId,
    required String password,
  }) async {
    try {
      final response = await _post(
        '/auth/counselor/login',
        data: {'login_id': loginId, 'password': password},
      );
      return _saveToken(_asMap(response.data));
    } catch (e) {
      throw Exception('상담사 로그인 실패: $e');
    }
  }

  Future<Map<String, dynamic>> loginClient({
    required String loginId,
    required String pin,
  }) async {
    try {
      final response = await _post(
        '/auth/client/login',
        data: {'login_id': loginId, 'pin': pin},
      );
      return _saveToken(_asMap(response.data));
    } catch (e) {
      throw Exception('어르신 로그인 실패: $e');
    }
  }

  Future<Map<String, dynamic>> createCounselor({
    required String loginId,
    required String password,
    required String name,
    String? email,
    String? phone,
    String? organization,
  }) async {
    try {
      final response = await _post(
        '/auth/counselor/register',
        data: {
          'login_id': loginId,
          'password': password,
          'name': name,
          'email': ?email,
          'phone': ?phone,
          'organization': ?organization,
        },
      );
      return _asMap(response.data);
    } catch (e) {
      throw Exception('상담사 생성 실패: $e');
    }
  }

  Future<ClientListResponse> getClientList({
    String? query,
    bool includeInactive = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _get(
        '/clients',
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
          'include_inactive': includeInactive,
          'limit': limit,
          'offset': offset,
        },
      );
      return ClientListResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('내담자 목록 조회 실패: $e');
    }
  }

  Future<ClientDetail> getClientDetail(int clientId) async {
    try {
      final response = await _get('/clients/$clientId');
      return ClientDetail.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('내담자 상세 조회 실패: $e');
    }
  }

  Future<ClientDetail> createClient({
    required String name,
    int? age,
    String? gender,
    String? phone,
    String? memo,
    String? cognitiveStage,
    String? loginId,
    String? pin,
    String? profileImageUrl,
  }) async {
    try {
      final response = await _post(
        '/clients',
        data: {
          'name': name,
          'age': ?age,
          'gender': ?gender,
          'phone': ?phone,
          'memo': ?memo,
          'cognitive_stage': ?cognitiveStage,
          'login_id': ?loginId,
          'pin': ?pin,
          'profile_image_url': ?profileImageUrl,
        },
      );
      return ClientDetail.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('내담자 생성 실패: $e');
    }
  }

  Future<ClientDetail> updateClient(
    int clientId, {
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? memo,
    String? cognitiveStage,
    String? loginId,
    String? pin,
    String? profileImageUrl,
    bool? isActive,
  }) async {
    try {
      final response = await _patch(
        '/clients/$clientId',
        data: {
          'name': ?name,
          'age': ?age,
          'gender': ?gender,
          'phone': ?phone,
          'memo': ?memo,
          'cognitive_stage': ?cognitiveStage,
          'login_id': ?loginId,
          'pin': ?pin,
          'profile_image_url': ?profileImageUrl,
          'is_active': ?isActive,
        },
      );
      return ClientDetail.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('내담자 수정 실패: $e');
    }
  }

  Future<AppointmentOut> createAppointment({
    required int clientId,
    required DateTime scheduledAt,
    int durationMinutes = 60,
    String? purpose,
    String? place,
    String? memo,
  }) async {
    try {
      final response = await _post(
        '/appointments',
        data: {
          'client_id': clientId,
          'scheduled_at': scheduledAt.toUtc().toIso8601String(),
          'duration_minutes': durationMinutes,
          'purpose': ?purpose,
          'place': ?place,
          'memo': ?memo,
        },
      );
      return AppointmentOut.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('상담 일정 생성 실패: $e');
    }
  }

  Future<AppointmentOut> updateAppointment(
    int appointmentId, {
    DateTime? scheduledAt,
    int? durationMinutes,
    String? purpose,
    String? place,
    String? memo,
    String? status,
  }) async {
    try {
      final response = await _patch(
        '/appointments/$appointmentId',
        data: {
          if (scheduledAt != null)
            'scheduled_at': scheduledAt.toUtc().toIso8601String(),
          'duration_minutes': ?durationMinutes,
          'purpose': ?purpose,
          'place': ?place,
          'memo': ?memo,
          'status': ?status,
        },
      );
      return AppointmentOut.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('상담 일정 수정 실패: $e');
    }
  }

  Future<CalendarMonthResponse> getCalendarMonth({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _get(
        '/appointments/calendar',
        queryParameters: {'year': year, 'month': month},
      );
      return CalendarMonthResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('캘린더 조회 실패: $e');
    }
  }

  Future<List<AppointmentOut>> getUpcomingAppointments({
    int days = 90,
    int limit = 1,
  }) async {
    try {
      final response = await _get(
        '/appointments/upcoming',
        queryParameters: {'days': days, 'limit': limit},
      );
      return _parseList<AppointmentOut>(response.data, AppointmentOut.fromJson);
    } catch (e) {
      throw Exception('예정된 면담 조회 실패: $e');
    }
  }

  Future<SessionBrief> createSession({
    required int clientId,
    String? title,
    int? appointmentId,
  }) async {
    try {
      final response = await _post(
        '/sessions',
        data: {
          'client_id': clientId,
          'title': ?title,
          'appointment_id': ?appointmentId,
        },
      );
      return SessionBrief.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('상담 세션 생성 실패: $e');
    }
  }

  Future<SessionListResponse> listSessions({
    int? clientId,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _get(
        '/sessions',
        queryParameters: {
          'client_id': ?clientId,
          'status': ?status,
          'limit': limit,
          'offset': offset,
        },
      );
      return SessionListResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('세션 목록 조회 실패: $e');
    }
  }

  Future<SessionDetail> getSessionDetail(int sessionId) async {
    try {
      final response = await _get('/sessions/$sessionId');
      return SessionDetail.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('세션 상세 조회 실패: $e');
    }
  }

  Future<SummaryResponse> updateSessionSummary(
    int sessionId, {
    String? summary,
    List<String>? keywords,
    String? title,
  }) async {
    try {
      final response = await _patch(
        '/sessions/$sessionId/summary',
        data: {'summary': ?summary, 'keywords': ?keywords, 'title': ?title},
      );
      return SummaryResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('세션 요약 수정 실패: $e');
    }
  }

  Future<SessionCompleteResponse> completeSession(
    int sessionId, {
    int? albumId,
    String? summary,
    String? title,
  }) async {
    try {
      final response = await _post(
        '/sessions/$sessionId/complete',
        data: {'album_id': ?albumId, 'summary': ?summary, 'title': ?title},
      );
      return SessionCompleteResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('세션 완료 처리 실패: $e');
    }
  }

  Future<RecordingUploadResponse> uploadRecording({
    required int sessionId,
    required String filePath,
    int durationSeconds = 0,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: _safeFileName(filePath),
        ),
        'duration_seconds': durationSeconds,
      });

      final response = await _dio.post(
        '/sessions/$sessionId/recording',
        data: formData,
      );
      return RecordingUploadResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('음성 업로드 및 STT 처리 실패: $e');
    }
  }

  Future<RecordingUploadResponse> uploadRecordingBytes({
    required int sessionId,
    required List<int> audioBytes,
    required String filename,
    int durationSeconds = 0,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(audioBytes, filename: filename),
        'duration_seconds': durationSeconds,
      });
      final response = await _dio.post(
        '/sessions/$sessionId/recording',
        data: formData,
      );
      return RecordingUploadResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('음성 업로드 및 STT 처리 실패: $e');
    }
  }

  Future<AlbumOut> generateImage(
    int sessionId, {
    String? extraPrompt,
    bool replacePrevious = false,
  }) async {
    try {
      final response = await _post(
        '/sessions/$sessionId/image',
        data: {
          'extra_prompt': ?extraPrompt,
          'replace_previous': replacePrevious,
        },
      );
      return AlbumOut.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('이미지 생성 실패: $e');
    }
  }

  Future<List<AlbumOut>> getSessionAlbums(int sessionId) async {
    try {
      final response = await _get('/sessions/$sessionId/images');
      return _parseList<AlbumOut>(response.data, AlbumOut.fromJson);
    } catch (e) {
      throw Exception('앨범 목록 조회 실패: $e');
    }
  }

  Future<ClientHomeResponse> getClientHome() async {
    try {
      final response = await _get('/me/home');
      return ClientHomeResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('어르신 홈 조회 실패: $e');
    }
  }

  Future<AlbumListResponse> getAlbumList({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _get(
        '/me/album',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return AlbumListResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('앨범 목록 조회 실패: $e');
    }
  }

  Future<DashboardResponse> getDashboard() async {
    try {
      final response = await _get('/dashboard');
      return DashboardResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('대시보드 조회 실패: $e');
    }
  }

  Future<NotificationListResponse> listNotifications({
    bool onlyUnread = false,
    int limit = 30,
  }) async {
    try {
      final response = await _get(
        '/notifications',
        queryParameters: {'only_unread': onlyUnread, 'limit': limit},
      );
      return NotificationListResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('알림 목록 조회 실패: $e');
    }
  }

  Future<SettingOut> getClientSettings() async {
    try {
      final response = await _get('/me/settings');
      return SettingOut.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('설정 조회 실패: $e');
    }
  }

  Future<SettingOut> updateClientSettings({
    String? fontScale,
    bool? highContrast,
    bool? hapticFeedback,
    bool? showHelpTips,
  }) async {
    try {
      final response = await _patch(
        '/me/settings',
        data: {
          'font_scale': ?fontScale,
          'high_contrast': ?highContrast,
          'haptic_feedback': ?hapticFeedback,
          'show_help_tips': ?showHelpTips,
        },
      );
      return SettingOut.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('설정 수정 실패: $e');
    }
  }

  Future<SummaryResponse> createSummary(int sessionId) async {
    try {
      final response = await _post('/sessions/$sessionId/summary');
      return SummaryResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('요약 생성 실패: $e');
    }
  }

  Future<ClientSummaryResponse> getClientSummary(int sessionId) async {
    try {
      final response = await _get('/me/sessions/$sessionId/summary');
      return ClientSummaryResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('요약 조회 실패: $e');
    }
  }

  Future<int?> getLatestClientSessionId() async {
    try {
      final response = await _get(
        '/me/sessions',
        queryParameters: {'limit': 1},
      );
      final items = _asMap(response.data)['items'];
      if (items is! List || items.isEmpty || items.first is! Map) {
        return null;
      }
      final sessionId = items.first['session_id'];
      if (sessionId is int && sessionId > 0) return sessionId;
      if (sessionId is String) return int.tryParse(sessionId);
      return null;
    } catch (e) {
      throw Exception('최근 상담 기록 조회 실패: $e');
    }
  }

  Future<TranscriptResponse> getTranscript(int sessionId) async {
    try {
      final response = await _get('/sessions/$sessionId/transcript');
      return TranscriptResponse.fromJson(_asMap(response.data));
    } catch (e) {
      throw Exception('대화 기록 조회 실패: $e');
    }
  }

  Future<dynamic> createSessionLegacy({
    required int userId,
    required String filename,
  }) async {
    try {
      final response = await _dio.post(
        '/pipeline/session',
        queryParameters: {'user_id': userId, 'filename': filename},
      );
      return response.data is Map
          ? (response.data as Map<String, dynamic>)['session_id'] ??
                (response.data as Map<String, dynamic>)['id']
          : response.data;
    } catch (e) {
      throw Exception('레거시 세션 생성 실패: $e');
    }
  }

  Future<Map<String, dynamic>> runPipeline({
    required int sessionId,
    required String filePath,
    int orderIndex = 1,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: _safeFileName(filePath),
        ),
      });

      final response = await _dio.post(
        '/pipeline/run/$sessionId',
        data: formData,
        queryParameters: {'order_index': orderIndex},
      );
      return _asMap(response.data);
    } catch (e) {
      throw Exception('레거시 파이프라인 실행 실패: $e');
    }
  }

  Future<List<AlbumImage>> fetchAlbum(int sessionId) async {
    try {
      final response = await _dio.get('/pipeline/album/$sessionId');
      return _parseList<AlbumImage>(response.data, AlbumImage.fromJson);
    } catch (e) {
      throw Exception('레거시 앨범 조회 실패: $e');
    }
  }
}
