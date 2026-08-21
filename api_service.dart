//import 'package:http/http.dart' as http;
import 'dart:core'; // 정정된 임포트
import 'package:dio/dio.dart';
import 'consultation_model.dart'; // 위에서 정의한 모델 임포트

class ApiService {
  // 실제 백엔드 호스트 및 포트에 맞게 조정 (FastAPI 기본은 8000)
  static const String baseUrl = 'http://3.36.70.79:8000';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    // 백엔드 명세: 장문 파일 처리 시간 대응을 위해 수신 타임아웃 5분(300초) 설정
    receiveTimeout: const Duration(seconds: 300),
  ));

  /// 1. 세션 생성 (POST /pipeline/session)
  Future<dynamic> createSession({required int userId, required String filename}) async {
    try {
      final response = await _dio.post(
        '/pipeline/session',
        queryParameters: {
          'user_id': userId,
          'filename': filename,
        },
      );
      // 백엔드가 생성된 session_id를 리턴한다고 가정
      return response.data['session_id'] ?? response.data['id'];
    } catch (e) {
      throw Exception('세션 생성 실패: $e');
    }
  }

  /// 2. 음성 파일 업로드 및 전체 파이프라인 실행 (POST /pipeline/run/{session_id})
  /// STT + 형태소 분석 + 이미지 생성을 원클릭으로 처리하는 엔드포인트 대응
  Future<Map<String, dynamic>> runPipeline({
    required int sessionId,
    required String filePath,
    int orderIndex = 1, // 백엔드 기본값 1 대응
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: 'audio.mp3', //  실제 파일명 수정 필요
        ),
      });

      // 끊겼던 네트워크 요청 로직 완성 및 쿼리 파라미터 추가
      final response = await _dio.post(
        '/pipeline/run/$sessionId',
        data: formData,
        queryParameters: {
          'order_index': orderIndex,
        },
      );

      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return {'status': 'success', 'data': response.data};
      }
    } catch (e) {
      throw Exception('전체 파이프라인 실행 실패: $e');
    }
  }

  /// 3. 앨범 조회 (GET /pipeline/album/{session_id})
  /// 백엔드가 리스트(List<Album>)를 바로 반환하므로 이에 맞춰 파싱 구조 수정
  Future<List<AlbumImage>> fetchAlbum(int sessionId) async {
    try {
      final response = await _dio.get('/pipeline/album/$sessionId');
      
      if (response.data is List) {
        final List list = response.data;
        return list.map((json) => AlbumImage.fromJson(json)).toList();
      } else {
        throw Exception('올바르지 않은 응답 형식입니다.');
      }
    } catch (e) {
      throw Exception('앨범 조회 실패: $e');
    }
  }
}