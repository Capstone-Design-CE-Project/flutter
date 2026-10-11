import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../navigation/prototype_routes.dart';
import 'session_flow_payloads.dart';

class SummaryGenerationRequest {
  const SummaryGenerationRequest({
    required this.clientId,
    required this.clientName,
    required this.recordingPath,
    required this.durationSeconds,
  });

  final int clientId;
  final String clientName;
  final String recordingPath;
  final int durationSeconds;
}

void main() {
  runApp(const MaterialApp(home: SummaryGenerationLoading()));
}

class SummaryGenerationLoading extends StatefulWidget {
  const SummaryGenerationLoading({super.key, this.request});

  final SummaryGenerationRequest? request;

  @override
  State<SummaryGenerationLoading> createState() =>
      _SummaryGenerationLoadingState();
}

class _SummaryGenerationLoadingState extends State<SummaryGenerationLoading> {
  final ApiService _apiService = ApiService();

  int? _sessionId;
  bool _recordingUploaded = false;
  bool _isProcessing = false;
  String? _error;
  String _status = '상담 내용을 준비하고 있습니다...';
  String _detail = '녹음 파일을 안전하게 전달하고 상담 내용을 정리합니다.';

  @override
  void initState() {
    super.initState();
    unawaited(_process());
  }

  void _setStatus(String status, String detail) {
    if (!mounted) return;
    setState(() {
      _status = status;
      _detail = detail;
    });
  }

  Future<void> _process() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final request = widget.request;
      if (request == null) {
        throw StateError('전달된 녹음 정보가 없습니다. 녹음을 다시 진행해 주세요.');
      }
      if (request.clientId <= 0 || request.recordingPath.isEmpty) {
        throw StateError('내담자 또는 녹음 파일 정보를 확인할 수 없습니다.');
      }

      if (_sessionId == null) {
        _setStatus('상담 기록을 준비하고 있습니다...', '상담 세션을 생성하는 중입니다.');
        final session = await _apiService.createSession(
          clientId: request.clientId,
        );
        final sessionId = session.sessionId > 0
            ? session.sessionId
            : session.id;
        if (sessionId <= 0) {
          throw StateError('상담 세션을 생성하지 못했습니다.');
        }
        _sessionId = sessionId;
      }

      if (!_recordingUploaded) {
        _setStatus('녹음 파일을 전송하고 있습니다...', '음성을 업로드하고 상담 내용을 텍스트로 변환합니다.');
        if (kIsWeb) {
          final response = await Dio().get<List<int>>(
            request.recordingPath,
            options: Options(responseType: ResponseType.bytes),
          );
          final audioBytes = response.data;
          if (audioBytes == null || audioBytes.isEmpty) {
            throw StateError('녹음 파일에서 데이터를 읽지 못했습니다.');
          }
          await _apiService.uploadRecordingBytes(
            sessionId: _sessionId!,
            audioBytes: audioBytes,
            filename: 'counseling-recording.wav',
            durationSeconds: request.durationSeconds,
          );
        } else {
          await _apiService.uploadRecording(
            sessionId: _sessionId!,
            filePath: request.recordingPath,
            durationSeconds: request.durationSeconds,
          );
        }
        _recordingUploaded = true;
      }

      _setStatus('상담 내용을 요약하고 있습니다...', '대화 기록을 분석해 초기 요약본을 생성합니다.');
      final summary = await _apiService.createSummary(_sessionId!);
      if (summary.summary.trim().isEmpty) {
        throw StateError('요약 생성 응답에 요약 내용이 없습니다.');
      }
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
        PrototypeRoutes.summaryReview,
        arguments: PrototypeRouteArguments(
          transition: FlowTransition.fade,
          payload: SummaryReviewRoutePayload(
            clientName: request.clientName,
            summary: summary,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _status = '요약 생성을 완료하지 못했습니다';
        _detail = '오류 내용을 확인한 뒤 다시 시도해 주세요.';
      });
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F5),
        foregroundColor: const Color(0xFF1A2B49),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'AI 상담 요약 생성',
          style: TextStyle(
            color: Color(0xFF1A2B49),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 176,
                      height: 176,
                      decoration: const BoxDecoration(
                        color: Color(0x1AFF6B53),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 104,
                          height: 104,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _error == null
                                ? Icons.auto_awesome
                                : Icons.error_outline,
                            size: 48,
                            color: _error == null
                                ? const Color(0xFFFF6B53)
                                : const Color(0xFFB42318),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1A2B49),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _detail,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF7D879C),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFEAEFF2)),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x041A2B49),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '상담 요약 생성 단계',
                          style: TextStyle(
                            color: Color(0xFF8E89D9),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _error ?? '내담자의 녹음을 분석해 상담 내용을 정리하고 있습니다.',
                          style: const TextStyle(
                            color: Color(0xFF1A2B49),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    FilledButton.icon(
                      onPressed: _isProcessing ? null : _process,
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시 시도'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B53),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    )
                  else
                    const LinearProgressIndicator(
                      color: Color(0xFFFF6B53),
                      backgroundColor: Color(0xFFFFE7E0),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
