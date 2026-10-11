import 'dart:async';

import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../navigation/prototype_routes.dart';
import 'session_flow_payloads.dart';

void main() {
  runApp(const MaterialApp(home: ImageGenerationLoading()));
}

class ImageGenerationLoading extends StatefulWidget {
  const ImageGenerationLoading({super.key, this.request});

  final ImageGenerationRequest? request;

  @override
  State<ImageGenerationLoading> createState() => _ImageGenerationLoadingState();
}

class _ImageGenerationLoadingState extends State<ImageGenerationLoading> {
  final ApiService _apiService = ApiService();

  bool _isGenerating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_generateImage());
  }

  Future<void> _generateImage() async {
    if (_isGenerating) return;
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final request = widget.request;
      if (request == null || request.sessionId <= 0) {
        throw StateError('이미지를 생성할 상담 정보가 없습니다.');
      }

      final album = await _apiService.generateImage(
        request.sessionId,
        replacePrevious: request.isRegeneration,
      );
      if (album.imageUrl.trim().isEmpty) {
        throw StateError('이미지 생성 응답에 이미지 주소가 없습니다.');
      }
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
        PrototypeRoutes.imageReview,
        arguments: PrototypeRouteArguments(
          transition: FlowTransition.fade,
          payload: ImageReviewRoutePayload(
            sessionId: request.sessionId,
            clientName: request.clientName,
            album: album,
            canRegenerate: !request.isRegeneration,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
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
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: '요약 검토로 돌아가기',
          icon: const Icon(Icons.close),
        ),
        title: const Text(
          'AI 회상 이미지 생성',
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                                ? Icons.image_search
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
                    _error == null ? '회상 이미지를 생성하고 있습니다...' : '이미지를 생성하지 못했습니다',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1A2B49),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error ??
                        '${widget.request?.clientName ?? '내담자'}님의 상담 요약을 바탕으로 이미지를 만들고 있습니다.\n완료될 때까지 잠시만 기다려 주세요.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF7D879C),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_error != null)
                    FilledButton.icon(
                      onPressed: _isGenerating ? null : _generateImage,
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
