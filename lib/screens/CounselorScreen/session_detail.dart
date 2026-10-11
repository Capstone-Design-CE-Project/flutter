import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../api/consultation_model.dart';
import '../../navigation/prototype_routes.dart';
import 'session_flow_payloads.dart';

void main() {
  runApp(const MaterialApp(home: SessionDetailV3()));
}

class SessionDetailV3 extends StatefulWidget {
  const SessionDetailV3({super.key, this.sessionId});

  final int? sessionId;

  @override
  State<SessionDetailV3> createState() => _SessionDetailV3State();
}

class _SessionDetailV3State extends State<SessionDetailV3> {
  final ApiService _apiService = ApiService();
  late Future<SessionDetail> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _loadSession();
  }

  Future<SessionDetail> _loadSession() {
    final sessionId = widget.sessionId;
    if (sessionId == null || sessionId <= 0) {
      return Future.error(
        StateError('세션 정보가 전달되지 않았습니다. 내담자 상세에서 세션을 다시 선택해 주세요.'),
      );
    }
    return _apiService.getSessionDetail(sessionId);
  }

  Future<void> _refresh() async {
    final future = _loadSession();
    setState(() => _sessionFuture = future);
    await future;
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '정보 없음';
    final local = value.toLocal();
    return '${local.year}년 ${local.month}월 ${local.day}일 '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '정보 없음';
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final remainingSeconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:$minutes:$remainingSeconds'
        : '$minutes:$remainingSeconds';
  }

  String _statusLabel(String status) {
    return switch (status) {
      'completed' => '완료',
      'in_progress' => '진행 중',
      'pending' => '대기 중',
      'failed' => '실패',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF9F5),
        foregroundColor: const Color(0xFF1A2B49),
        title: const Text(
          '상담 기록 상세',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<SessionDetail>(
            future: _sessionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 180),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }
              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: [
                    _LoadMessage(
                      message: '상담 기록을 불러오지 못했습니다.',
                      detail: snapshot.error.toString().replaceFirst(
                        'Exception: ',
                        '',
                      ),
                      onRetry: () =>
                          setState(() => _sessionFuture = _loadSession()),
                    ),
                  ],
                );
              }

              final session = snapshot.data!;
              final title = session.title?.trim();
              final clientName = session.clientName?.trim();
              final recordedAt = session.startedAt ?? session.createdAt;
              final summary = session.summary?.trim();
              final transcript = session.transcript?.trim();

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  Text(
                    title?.isNotEmpty == true ? title! : '상담 기록',
                    style: const TextStyle(
                      color: Color(0xFF1A2B49),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    clientName?.isNotEmpty == true
                        ? '$clientName님의 상담 기록'
                        : '내담자 이름 정보 없음',
                    style: const TextStyle(
                      color: Color(0xFF7D879C),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(
                    children: [
                      _InfoRow(label: '상담 일시', value: _formatDate(recordedAt)),
                      _InfoRow(
                        label: '진행 시간',
                        value: _formatDuration(session.durationSeconds),
                      ),
                      _InfoRow(
                        label: '상태',
                        value: _statusLabel(session.status),
                      ),
                      if (session.referenceCode?.trim().isNotEmpty == true)
                        _InfoRow(
                          label: '기록 번호',
                          value: session.referenceCode!.trim(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => openPrototypeRoute(
                        context,
                        PrototypeRoutes.sessionEnd,
                        payload: SessionEndConfirmationRequest(
                          clientName: clientName ?? '',
                          mode: SessionEndConfirmationMode.existingSession,
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('기록 수정'),
                    ),
                  ),
                  if (summary?.isNotEmpty == true) ...[
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: '상담 요약',
                      child: Text(
                        summary!,
                        style: const TextStyle(
                          color: Color(0xFF344054),
                          fontSize: 15,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                  if (session.keywords.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: '주요 키워드',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: session.keywords
                            .where((keyword) => keyword.trim().isNotEmpty)
                            .map(
                              (keyword) => Chip(
                                label: Text(keyword),
                                backgroundColor: const Color(0xFFF0EEFC),
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                  if (session.albums.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: '회상 이미지',
                      child: Column(
                        children: [
                          for (final album in session.albums)
                            _AlbumItem(
                              album: album,
                              imageUrl: album.imageUrl.trim().isEmpty
                                  ? null
                                  : _apiService.resolveUrl(album.imageUrl),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (transcript?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: '녹음 내용',
                      child: Text(
                        transcript!,
                        style: const TextStyle(
                          color: Color(0xFF344054),
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                  if (session.qaLogs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: '상담 대화',
                      child: Column(
                        children: [
                          for (final log in session.qaLogs)
                            if (log.text.trim().isNotEmpty)
                              _QaLogItem(log: log),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const Divider(height: 20),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1A2B49),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAEFF2)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _AlbumItem extends StatelessWidget {
  const _AlbumItem({required this.album, required this.imageUrl});

  final AlbumOut album;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final title = album.title?.trim();
    final scene = album.scene?.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl!,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 190,
                  child: Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            )
          else
            const SizedBox(
              height: 96,
              child: Center(child: Icon(Icons.image_not_supported_outlined)),
            ),
          if (title?.isNotEmpty == true || album.isSelected) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title?.isNotEmpty == true ? title! : '회상 이미지',
                    style: const TextStyle(
                      color: Color(0xFF1A2B49),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (album.isSelected)
                  const Text(
                    '선택된 이미지',
                    style: TextStyle(
                      color: Color(0xFF52A87B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
          if (scene?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              scene!,
              style: const TextStyle(
                color: Color(0xFF7D879C),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QaLogItem extends StatelessWidget {
  const _QaLogItem({required this.log});

  final QaLogOut log;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFF0EEFC),
              shape: BoxShape.circle,
            ),
            child: Text(
              log.type,
              style: const TextStyle(
                color: Color(0xFF514C87),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (log.speaker.trim().isNotEmpty)
                  Text(
                    log.speaker,
                    style: const TextStyle(
                      color: Color(0xFF7D879C),
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 3),
                Text(
                  log.text,
                  style: const TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMessage extends StatelessWidget {
  const _LoadMessage({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  final String message;
  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 140),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1A2B49),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF7D879C), fontSize: 13),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('다시 시도'),
        ),
      ],
    );
  }
}
