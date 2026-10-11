import 'dart:async';

import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../api/consultation_model.dart';
import '../../navigation/prototype_routes.dart';
import 'session_flow_payloads.dart';

void main() {
  runApp(const MaterialApp(home: SessionCompleteV3()));
}

class SessionCompleteV3 extends StatefulWidget {
  const SessionCompleteV3({super.key, this.routePayload});

  final SessionCompleteRoutePayload? routePayload;

  @override
  State<SessionCompleteV3> createState() => _SessionCompleteV3State();
}

class _SessionCompleteV3State extends State<SessionCompleteV3> {
  final ApiService _apiService = ApiService();

  SessionCompleteResponse? _completion;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_completeSession());
  }

  Future<void> _completeSession() async {
    final payload = widget.routePayload;
    if (payload == null || payload.sessionId <= 0 || payload.album.id <= 0) {
      setState(() {
        _isLoading = false;
        _error = '상담 기록 또는 선택한 이미지 정보를 확인할 수 없습니다.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final completion = await _apiService.completeSession(
        payload.sessionId,
        albumId: payload.album.id,
      );
      if (!mounted) return;
      setState(() {
        _completion = completion;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '상담 완료';
    final local = dateTime.toLocal();
    return '${local.year}년 ${local.month}월 ${local.day}일 '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.routePayload;
    final completion = _completion;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F5),
        foregroundColor: const Color(0xFF1A2B49),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          '상담 저장 완료',
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
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Container(
                                width: 104,
                                height: 104,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE8F5EE),
                                  shape: BoxShape.circle,
                                ),
                                child: _isLoading
                                    ? const Padding(
                                        padding: EdgeInsets.all(26),
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF52A87B),
                                        ),
                                      )
                                    : Icon(
                                        _error == null
                                            ? Icons.check_rounded
                                            : Icons.error_outline,
                                        size: 56,
                                        color: _error == null
                                            ? const Color(0xFF52A87B)
                                            : const Color(0xFFB42318),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _isLoading
                                  ? '상담을 저장하고 있습니다...'
                                  : _error == null
                                  ? '상담 세션이 저장되었습니다.'
                                  : '상담 저장에 실패했습니다.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF1A2B49),
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isLoading
                                  ? '저장이 완료될 때까지 잠시만 기다려 주세요.'
                                  : _error ??
                                        '${payload?.clientName ?? '내담자'}님의 상담 기록이 저장되었습니다.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF7D879C),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            if (_isLoading) ...[
                              const SizedBox(height: 24),
                              const LinearProgressIndicator(
                                color: Color(0xFF52A87B),
                                backgroundColor: Color(0xFFE8F5EE),
                              ),
                            ] else if (_error == null &&
                                completion != null) ...[
                              const SizedBox(height: 24),
                              if (completion.selectedAlbum?.imageUrl
                                  case final imageUrl?
                                  when imageUrl.isNotEmpty) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AspectRatio(
                                    aspectRatio: 3 / 2,
                                    child: Image.network(
                                      _apiService.resolveUrl(imageUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const _ImageUnavailable(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFEAEFF2),
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  children: [
                                    _CompletionInfoRow(
                                      label: '기록 번호',
                                      value: completion.referenceCode.isEmpty
                                          ? '발급되지 않음'
                                          : completion.referenceCode,
                                    ),
                                    const Divider(height: 24),
                                    _CompletionInfoRow(
                                      label: '완료 시각',
                                      value: _formatDate(completion.recordedAt),
                                    ),
                                    const Divider(height: 24),
                                    _CompletionInfoRow(
                                      label: '저장 상태',
                                      value: completion.status,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _completeSession,
                          icon: const Icon(Icons.refresh),
                          label: const Text('다시 시도'),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading || _error != null
                          ? null
                          : () => Navigator.of(context).pushNamedAndRemoveUntil(
                              PrototypeRoutes.dashboard,
                              (route) => false,
                            ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B53),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        '홈으로',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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

class _CompletionInfoRow extends StatelessWidget {
  const _CompletionInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF7D879C))),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF1A2B49),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageUnavailable extends StatelessWidget {
  const _ImageUnavailable();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF3F4F6),
      child: Center(child: Icon(Icons.image_not_supported_outlined, size: 44)),
    );
  }
}
