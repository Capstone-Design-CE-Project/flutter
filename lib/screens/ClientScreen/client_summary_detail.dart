import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../api/client_session.dart';
import '../../api/consultation_model.dart';
import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class ClientsummarydetailWidget extends StatefulWidget {
  const ClientsummarydetailWidget({this.sessionId, super.key});

  final int? sessionId;

  @override
  State<ClientsummarydetailWidget> createState() =>
      _ClientsummarydetailWidgetState();
}

class _ClientsummarydetailWidgetState extends State<ClientsummarydetailWidget> {
  final ApiService _apiService = ApiService();
  late Future<ClientSummaryResponse> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<ClientSummaryResponse> _loadSummary() async {
    if (ClientSession.clientId == null) {
      throw StateError('로그인한 내담자 정보가 없습니다. 다시 로그인해 주세요.');
    }

    final sessionId =
        widget.sessionId ?? await _apiService.getLatestClientSessionId();
    if (sessionId == null || sessionId <= 0) {
      throw StateError('아직 확인할 수 있는 상담 기록이 없습니다.');
    }
    return _apiService.getClientSummary(sessionId);
  }

  void _retry() {
    setState(() => _summaryFuture = _loadSummary());
  }

  @override
  Widget build(BuildContext context) {
    const coral = Color(0xFFFF6B53);
    final theme = Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: coral,
        secondary: coral,
        onPrimary: Colors.white,
        secondaryContainer: const Color(0xFFFFE6E0),
        onSecondaryContainer: const Color(0xFF1A2B49),
      ),
    );
    final colors = theme.colorScheme;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                child: Row(
                  children: [
                    DeviceClock(color: colors.onSurface),
                    const Spacer(),
                    Text(
                      '오늘의 요약',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: coral,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: '요약 창 닫기',
                      onPressed: () => openPrototypeRoute(
                        context,
                        PrototypeRoutes.clientAlbum,
                        transition: FlowTransition.slideBack,
                      ),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<ClientSummaryResponse>(
                  future: _summaryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return _SummaryMessage(
                        message: snapshot.error.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                        actionLabel: '다시 시도',
                        onAction: _retry,
                      );
                    }

                    final summary = snapshot.data!;
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      children: [
                        if (summary.imageUrl != null &&
                            summary.imageUrl!.trim().isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              _apiService.resolveUrl(summary.imageUrl!),
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const _SummaryMessage(
                                    message: '회상 이미지를 불러오지 못했습니다.',
                                  ),
                            ),
                          )
                        else
                          const _SummaryMessage(
                            message: '이 상담 기록에는 회상 이미지가 없습니다.',
                          ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Chip(
                                      label: const Text('상담 요약문'),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    if (summary.dateLabel.isNotEmpty)
                                      Text(
                                        summary.dateLabel,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (summary.title?.trim().isNotEmpty ?? false)
                                  Text(
                                    summary.title!,
                                    style: theme.textTheme.titleLarge,
                                  ),
                                if (summary.title?.trim().isNotEmpty ?? false)
                                  const SizedBox(height: 12),
                                Text(
                                  summary.summary?.trim().isNotEmpty ?? false
                                      ? summary.summary!
                                      : '이 상담 기록에는 요약 내용이 없습니다.',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () => openPrototypeRoute(
                            context,
                            PrototypeRoutes.clientAlbum,
                            transition: FlowTransition.slideBack,
                          ),
                          child: const Text('앨범으로 돌아가기'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryMessage extends StatelessWidget {
  const _SummaryMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
