import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../navigation/prototype_routes.dart';
import 'session_flow_payloads.dart';

void main() {
  runApp(const MaterialApp(home: ImageReviewV3()));
}

class ImageReviewV3 extends StatelessWidget {
  const ImageReviewV3({super.key, this.routePayload});

  final ImageReviewRoutePayload? routePayload;

  @override
  Widget build(BuildContext context) {
    final payload = routePayload;
    final imageUrl = payload == null
        ? null
        : ApiService().resolveUrl(payload.album.imageUrl);
    final description = payload?.album.scene?.trim().isNotEmpty == true
        ? payload!.album.scene!
        : payload?.album.title?.trim().isNotEmpty == true
        ? payload!.album.title!
        : '상담 내용을 바탕으로 생성한 회상 이미지입니다.';

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F5),
        foregroundColor: const Color(0xFF1A2B49),
        centerTitle: true,
        title: const Text(
          '생성 이미지 검토',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    payload == null
                        ? '이미지 정보를 불러오지 못했습니다.'
                        : '${payload.clientName}님의 회상 이미지',
                    style: const TextStyle(
                      color: Color(0xFF1A2B49),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '생성된 이미지를 확인해 주세요.',
                    style: TextStyle(color: Color(0xFF7D879C), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFEAEFF2)),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x041A2B49),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 3 / 2,
                        child: imageUrl == null
                            ? const _ImagePlaceholder(message: '표시할 이미지가 없습니다.')
                            : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const _ImagePlaceholder(
                                    message: '이미지를 불러오고 있습니다...',
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const _ImagePlaceholder(
                                      message: '이미지를 불러오지 못했습니다.',
                                    ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EEFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF514C87),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: payload == null || !payload.canRegenerate
                              ? null
                              : () =>
                                    Navigator.of(context).pushReplacementNamed(
                                      PrototypeRoutes.imageLoading,
                                      arguments: PrototypeRouteArguments(
                                        transition: FlowTransition.slide,
                                        payload: ImageGenerationRequest(
                                          sessionId: payload.sessionId,
                                          clientName: payload.clientName,
                                          isRegeneration: true,
                                        ),
                                      ),
                                    ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A2B49),
                            side: const BorderSide(color: Color(0xFF1A2B49)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            payload?.canRegenerate == true ? '다시 생성' : '재생성 완료',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => openPrototypeRoute(
                            context,
                            PrototypeRoutes.sessionComplete,
                            payload: payload == null
                                ? null
                                : SessionCompleteRoutePayload(
                                    sessionId: payload.sessionId,
                                    clientName: payload.clientName,
                                    album: payload.album,
                                  ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B53),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('이대로 저장'),
                        ),
                      ),
                    ],
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

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_outlined,
              size: 42,
              color: Color(0xFF8792A2),
            ),
            const SizedBox(height: 10),
            Text(message, style: const TextStyle(color: Color(0xFF7D879C))),
          ],
        ),
      ),
    );
  }
}
