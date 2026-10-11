import 'dart:async';

import 'package:flutter/foundation.dart'
    show ErrorDescription, FlutterError, FlutterErrorDetails, kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../api/api_service.dart';
import '../../api/consultation_model.dart';
import '../../navigation/prototype_routes.dart';
import 'session_flow_payloads.dart';
import 'summary_generation_loading.dart';

class RecordingV3 extends StatefulWidget {
  const RecordingV3({super.key, this.clientId});

  final int? clientId;

  @override
  State<RecordingV3> createState() => _RecordingV3State();
}

class _RecordingV3State extends State<RecordingV3> {
  final ApiService _apiService = ApiService();
  final AudioRecorder _recorder = AudioRecorder();
  final Stopwatch _stopwatch = Stopwatch();

  ClientDetail? _client;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  String? _error;
  String? _recordingPath;
  bool _isStarting = true;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isBusy = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    unawaited(_startRecording());
  }

  Future<void> _startRecording() async {
    if (_isBusy && !_isStarting) return;
    setState(() {
      _isStarting = true;
      _error = null;
    });

    try {
      final clientId = widget.clientId;
      if (clientId == null || clientId <= 0) {
        throw StateError('선택한 내담자 정보가 없습니다. 내담자 목록에서 다시 선택해 주세요.');
      }

      final client = await _apiService.getClientDetail(clientId);
      if (!mounted) return;
      setState(() => _client = client);

      if (!await _recorder.hasPermission()) {
        throw StateError('마이크 권한이 허용되지 않았습니다. 기기 설정에서 마이크 권한을 허용해 주세요.');
      }

      final recordingPath = kIsWeb
          ? 'counseling-${DateTime.now().microsecondsSinceEpoch}.wav'
          : p.join(
              (await getTemporaryDirectory()).path,
              'counseling-${DateTime.now().microsecondsSinceEpoch}.wav',
            );

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: recordingPath,
      );
      _recordingPath = recordingPath;

      if (!mounted) {
        await _recorder.stop();
        return;
      }

      _stopwatch
        ..reset()
        ..start();
      _startTimer();
      setState(() {
        _isStarting = false;
        _isRecording = true;
        _isPaused = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isStarting = false;
        _isRecording = false;
        _isPaused = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      setState(() => _elapsed = _stopwatch.elapsed);
    });
  }

  Future<void> _togglePause() async {
    if (_isBusy || (!_isRecording && !_isPaused)) return;
    setState(() => _isBusy = true);

    try {
      if (_isRecording) {
        await _recorder.pause();
        _stopwatch.stop();
        _timer?.cancel();
        if (!mounted) return;
        setState(() {
          _isRecording = false;
          _isPaused = true;
          _elapsed = _stopwatch.elapsed;
        });
      } else {
        await _recorder.resume();
        _stopwatch.start();
        _startTimer();
        if (!mounted) return;
        setState(() {
          _isRecording = true;
          _isPaused = false;
        });
      }
    } catch (error) {
      if (mounted) _showError('녹음 상태를 변경하지 못했습니다: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _finishRecording() async {
    if (_isBusy || (!_isRecording && !_isPaused)) return;
    setState(() => _isBusy = true);

    final confirmed = await Navigator.of(context).pushNamed<bool>(
      PrototypeRoutes.sessionEnd,
      arguments: PrototypeRouteArguments(
        transition: FlowTransition.fade,
        payload: SessionEndConfirmationRequest(
          clientName: _client?.name ?? '',
          mode: SessionEndConfirmationMode.recording,
        ),
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      setState(() => _isBusy = false);
      return;
    }

    try {
      final durationSeconds = _stopwatch.elapsed.inSeconds;
      _timer?.cancel();
      _stopwatch.stop();
      final recordingPath = await _recorder.stop() ?? _recordingPath;
      if (recordingPath == null || recordingPath.isEmpty) {
        throw StateError('녹음 파일을 찾을 수 없습니다. 다시 녹음해 주세요.');
      }
      final clientId = widget.clientId;
      if (clientId == null) {
        throw StateError('내담자 정보를 확인할 수 없어 요약 생성을 시작할 수 없습니다.');
      }
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _isFinished = true;
      });
      openPrototypeRoute(
        context,
        PrototypeRoutes.summaryGeneration,
        payload: SummaryGenerationRequest(
          clientId: clientId,
          clientName: _client?.name ?? '내담자',
          recordingPath: recordingPath,
          durationSeconds: durationSeconds,
        ),
      );
    } catch (error) {
      if (mounted) _showError('녹음을 종료하지 못했습니다: $error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Future<void> _releaseRecorder() async {
    if (_isRecording || _isPaused) {
      try {
        await _recorder.stop();
      } catch (error, stackTrace) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'audio recorder',
            context: ErrorDescription('while stopping the recorder on dispose'),
          ),
        );
      }
    }

    try {
      await _recorder.dispose();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'audio recorder',
          context: ErrorDescription('while disposing the recorder'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_releaseRecorder());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _isRecording || _isPaused;
    final statusColor = _isRecording
        ? const Color(0xFFE85D4A)
        : const Color(0xFF8792A2);
    final statusText = _isStarting
        ? '녹음을 준비하고 있습니다'
        : _error != null
        ? '녹음을 시작할 수 없습니다'
        : _isPaused
        ? '녹음 일시정지'
        : _isFinished
        ? '녹음이 종료되었습니다'
        : '상담 녹음 중';

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F5),
        foregroundColor: const Color(0xFF1A2B49),
        centerTitle: true,
        title: const Text(
          '상담 녹음',
          style: TextStyle(
            color: Color(0xFF1A2B49),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          tooltip: '뒤로가기',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ClientBanner(client: _client, isLoading: _isStarting),
                  const Spacer(),
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 156,
                      height: 156,
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? const Color(0xFFFFE7E0)
                            : const Color(0xFFF0ECE7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPaused ? Icons.pause_rounded : Icons.mic_rounded,
                        size: 68,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    statusText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatDuration(_elapsed),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1A2B49),
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPaused
                        ? '녹음이 멈춰 있습니다. 이어하기를 누르면 다시 녹음됩니다.'
                        : _isRecording
                        ? '녹음 중에는 이 화면을 유지해 주세요.'
                        : _isFinished
                        ? '요약 생성을 위해 녹음 파일을 전송하고 있습니다.'
                        : '완료를 누르면 녹음을 종료하고 요약 검토 화면으로 이동합니다.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8792A2),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  if (_error case final error?) ...[
                    _RecordingError(
                      message: error,
                      onRetry: _startRecording,
                      isRetrying: _isStarting,
                    ),
                  ] else if (isActive) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isBusy ? null : _togglePause,
                            icon: Icon(
                              _isPaused ? Icons.play_arrow : Icons.pause,
                            ),
                            label: Text(_isPaused ? '이어하기' : '일시정지'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1A2B49),
                              side: const BorderSide(color: Color(0xFF1A2B49)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isBusy ? null : _finishRecording,
                            icon: const Icon(Icons.check),
                            label: const Text('완료'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B53),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (_isStarting) ...[
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientBanner extends StatelessWidget {
  const _ClientBanner({required this.client, required this.isLoading});

  final ClientDetail? client;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final label = isLoading
        ? '내담자 정보 확인 중'
        : client == null
        ? '내담자 정보 없음'
        : '면담 대상자: ${client!.name}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Color(0xFFFF6B53)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1A2B49),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingError extends StatelessWidget {
  const _RecordingError({
    required this.message,
    required this.onRetry,
    required this.isRetrying,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFB42318), height: 1.5),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: isRetrying ? null : onRetry,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B53),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(isRetrying ? '다시 준비 중...' : '다시 시도'),
        ),
      ],
    );
  }
}
