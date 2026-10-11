import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_service.dart';
import '../../api/consultation_model.dart';
import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class SessionInfoInputV3 extends StatefulWidget {
  const SessionInfoInputV3({super.key, this.clientId});

  final int? clientId;

  @override
  State<SessionInfoInputV3> createState() => _SessionInfoInputV3State();
}

class _SessionInfoInputV3State extends State<SessionInfoInputV3> {
  final ApiService _apiService = ApiService();
  late Future<ClientDetail> _clientFuture;
  late Future<String?> _memoFuture;

  @override
  void initState() {
    super.initState();
    _clientFuture = _loadClient();
    _memoFuture = _loadLocalMemo();
  }

  Future<ClientDetail> _loadClient() {
    final clientId = widget.clientId;
    if (clientId == null || clientId <= 0) {
      return Future.error(StateError('선택한 내담자 정보가 없습니다. 내담자 목록에서 다시 선택해 주세요.'));
    }
    return _apiService.getClientDetail(clientId);
  }

  Future<String?> _loadLocalMemo() async {
    final clientId = widget.clientId;
    if (clientId == null || clientId <= 0) return null;
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('client.memo.$clientId');
  }

  void _retry() {
    setState(() {
      _clientFuture = _loadClient();
      _memoFuture = _loadLocalMemo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Row(
                children: [
                  const DeviceClock(color: Color(0xFF1A2B49), fontSize: 15),
                  const Spacer(),
                  const Icon(Icons.signal_cellular_alt, size: 18),
                  const SizedBox(width: 6),
                  const Icon(Icons.wifi, size: 18),
                  const SizedBox(width: 6),
                  const Icon(Icons.battery_full, size: 20),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '상담 대기',
                style: TextStyle(
                  color: Color(0xFF1A2B49),
                  fontFamily: 'GowunBatang',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<ClientDetail>(
                future: _clientFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _SessionInfoMessage(
                      message: '내담자 정보를 불러오지 못했습니다.',
                      detail: snapshot.error.toString().replaceFirst(
                        'Exception: ',
                        '',
                      ),
                      actionLabel: '다시 시도',
                      onAction: _retry,
                    );
                  }

                  final client = snapshot.data!;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                    children: [
                      const Text(
                        '내담자 정보 확인',
                        style: TextStyle(
                          color: Color(0xFF1A2B49),
                          fontFamily: 'GowunBatang',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ClientInfoCard(client: client),
                      const SizedBox(height: 16),
                      FutureBuilder<String?>(
                        future: _memoFuture,
                        builder: (context, memoSnapshot) {
                          if (memoSnapshot.hasError) {
                            return _SessionInfoMessage(
                              message: '기기에 저장된 상담 메모를 읽지 못했습니다.',
                              detail: memoSnapshot.error
                                  .toString()
                                  .replaceFirst('Exception: ', ''),
                            );
                          }
                          final memo = memoSnapshot.data?.trim();
                          if (memo == null || memo.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return _LocalMemoCard(memo: memo);
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EEFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF8E89D9),
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '상담을 시작하면 녹음 및 AI 분석이 시작됩니다.',
                                style: TextStyle(
                                  color: Color(0xFF1A2B49),
                                  fontFamily: 'GowunBatang',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFF6B53), Color(0xFFFF8E7C)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33FF6B53),
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: InkWell(
                              onTap: () => openPrototypeRoute(
                                context,
                                PrototypeRoutes.sessionStart,
                                payload: widget.clientId,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  '▶ 상담 시작하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'GowunBatang',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientInfoCard extends StatelessWidget {
  const _ClientInfoCard({required this.client});

  final ClientDetail client;

  @override
  Widget build(BuildContext context) {
    final imageUrl = client.profileImageUrl?.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F0),
        border: Border.all(color: const Color(0xFFEAEFF2)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _SessionClientAvatar(imageUrl: imageUrl, name: client.name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A2B49),
                        fontFamily: 'GowunBatang',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.memberCode == null || client.memberCode!.isEmpty
                          ? '고유 번호 정보 없음'
                          : '고유 번호: ${client.memberCode}',
                      style: const TextStyle(
                        color: Color(0xFF7D879C),
                        fontFamily: 'GowunBatang',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFEAEFF2)),
          ),
          _InfoRow(label: '이름', value: client.name),
          _InfoRow(
            label: '나이',
            value: client.age == null ? '정보 없음' : '${client.age}세',
          ),
          _InfoRow(label: '성별', value: _genderLabel(client.gender)),
          _InfoRow(
            label: '인지 단계',
            value: client.cognitiveStage?.isNotEmpty ?? false
                ? client.cognitiveStage!
                : '정보 없음',
          ),
          _InfoRow(
            label: '연락처',
            value: client.phone?.isNotEmpty ?? false ? client.phone! : '정보 없음',
          ),
          _InfoRow(
            label: '최근 면담',
            value: _formatDate(client.lastVisitAt),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SessionClientAvatar extends StatelessWidget {
  const _SessionClientAvatar({this.imageUrl, required this.name});

  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => CircleAvatar(
    radius: 32,
    backgroundColor: const Color(0xFF1A2B49),
    child: Text(
      name.isEmpty ? '?' : name.characters.first,
      style: const TextStyle(
        color: Color(0xFFFF6B53),
        fontFamily: 'GowunBatang',
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFEAEFF2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7D879C),
                fontFamily: 'GowunBatang',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF1A2B49),
                fontFamily: 'GowunBatang',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalMemoCard extends StatelessWidget {
  const _LocalMemoCard({required this.memo});

  final String memo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F2),
        border: Border.all(color: const Color(0xFFFFD7CF)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기기 저장 상담 메모',
            style: TextStyle(
              color: Color(0xFF1A2B49),
              fontFamily: 'GowunBatang',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            memo,
            style: const TextStyle(
              color: Color(0xFF344B6E),
              fontFamily: 'GowunBatang',
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

String _genderLabel(String? gender) {
  switch (gender) {
    case 'M':
      return '남성';
    case 'F':
      return '여성';
    case null:
    case '':
      return '정보 없음';
    default:
      return gender;
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '기록 없음';
  return '${date.year}년 ${date.month}월 ${date.day}일';
}

class _SessionInfoMessage extends StatelessWidget {
  const _SessionInfoMessage({
    required this.message,
    this.detail,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? detail;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1A2B49),
                fontFamily: 'GowunBatang',
                fontSize: 15,
              ),
            ),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(
                detail!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF7D879C), fontSize: 12),
              ),
            ],
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
