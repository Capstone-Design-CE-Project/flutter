import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../api/consultation_model.dart';
import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class ClientDetailV3 extends StatefulWidget {
  const ClientDetailV3({super.key, this.clientId});

  final int? clientId;

  @override
  State<ClientDetailV3> createState() => _ClientDetailV3State();
}

class _ClientDetailV3State extends State<ClientDetailV3> {
  static const _sessionPageSize = 20;

  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final List<SessionBrief> _sessions = [];

  late Future<ClientDetail> _clientFuture;
  int _sessionOffset = 0;
  int _requestGeneration = 0;
  bool _isLoadingSessions = true;
  bool _isLoadingMoreSessions = false;
  bool _hasMoreSessions = true;
  String? _sessionsError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _clientFuture = _loadClient();
    _loadSessions(reset: true);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  Future<ClientDetail> _loadClient() {
    final clientId = widget.clientId;
    if (clientId == null || clientId <= 0) {
      return Future.error(
        StateError('내담자 정보가 전달되지 않았습니다. 내담자 목록에서 다시 선택해 주세요.'),
      );
    }
    return _apiService.getClientDetail(clientId);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _isLoadingSessions ||
        _isLoadingMoreSessions ||
        _sessionsError != null ||
        !_hasMoreSessions) {
      return;
    }
    if (_scrollController.position.extentAfter < 300) {
      _loadSessions();
    }
  }

  Future<void> _loadSessions({bool reset = false}) async {
    final clientId = widget.clientId;
    if (clientId == null ||
        clientId <= 0 ||
        (!reset && (_isLoadingSessions || _isLoadingMoreSessions))) {
      return;
    }

    if (reset) _requestGeneration++;
    final generation = _requestGeneration;
    final offset = reset ? 0 : _sessionOffset;
    setState(() {
      if (reset) {
        _isLoadingSessions = true;
        _sessionOffset = 0;
        _sessions.clear();
        _hasMoreSessions = true;
      } else {
        _isLoadingMoreSessions = true;
      }
      _sessionsError = null;
    });

    try {
      final response = await _apiService.listSessions(
        clientId: clientId,
        limit: _sessionPageSize,
        offset: offset,
      );
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _sessions.addAll(response.items);
        _sessionOffset = offset + response.items.length;
        _hasMoreSessions =
            response.items.isNotEmpty && _sessionOffset < response.total;
      });
    } catch (error) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _sessionsError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() {
          _isLoadingSessions = false;
          _isLoadingMoreSessions = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() => _clientFuture = _loadClient());
    await _loadSessions(reset: true);
  }

  Future<void> _editClient() async {
    try {
      final client = await _clientFuture;
      if (!mounted) return;
      final result = await Navigator.of(context).pushNamed(
        PrototypeRoutes.newClient,
        arguments: PrototypeRouteArguments(
          transition: FlowTransition.slide,
          payload: client,
        ),
      );
      if (!mounted || result is! String) return;
      setState(() => _clientFuture = _loadClient());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '내담자 정보를 불러오지 못했습니다: '
            '${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: '뒤로가기',
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF1A2B49),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '상세 정보',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1A2B49),
                        fontFamily: 'GowunBatang',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _editClient,
                    tooltip: '정보 수정',
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF1A2B49),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<ClientDetail>(
                  future: _clientFuture,
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
                          _DetailMessage(
                            message: '내담자 정보를 불러오지 못했습니다.',
                            detail: snapshot.error.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
                            actionLabel: '다시 시도',
                            onAction: () =>
                                setState(() => _clientFuture = _loadClient()),
                          ),
                        ],
                      );
                    }

                    final client = snapshot.data!;
                    return ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                      children: [
                        _ClientProfile(client: client),
                        const SizedBox(height: 16),
                        _ClientVisitCard(client: client),
                        const SizedBox(height: 12),
                        _NextAppointmentCard(
                          appointment: client.nextAppointment,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '세션 기록',
                              style: TextStyle(
                                color: Color(0xFF1A2B49),
                                fontFamily: 'GowunBatang',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '총 ${client.sessionCount}건',
                              style: const TextStyle(
                                color: Color(0xFF7D879C),
                                fontFamily: 'GowunBatang',
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingSessions && _sessions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 36),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_sessionsError != null && _sessions.isEmpty)
                          _DetailMessage(
                            message: '세션 기록을 불러오지 못했습니다.',
                            detail: _sessionsError,
                            actionLabel: '다시 시도',
                            onAction: () => _loadSessions(reset: true),
                          )
                        else if (_sessions.isEmpty)
                          const _DetailMessage(message: '등록된 상담 세션이 없습니다.')
                        else ...[
                          for (final session in _sessions) ...[
                            _SessionCard(
                              session: session,
                              onTap: () {
                                if (session.sessionId <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('세션 정보를 확인할 수 없습니다.'),
                                    ),
                                  );
                                  return;
                                }
                                openPrototypeRoute(
                                  context,
                                  PrototypeRoutes.sessionDetail,
                                  payload: session.sessionId,
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (_isLoadingMoreSessions)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (_sessionsError != null)
                            _DetailMessage(
                              message: '세션 기록을 더 불러오지 못했습니다.',
                              detail: _sessionsError,
                              actionLabel: '다시 시도',
                              onAction: _loadSessions,
                            ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            const _CounselorBottomNavigation(),
          ],
        ),
      ),
    );
  }
}

class _ClientProfile extends StatelessWidget {
  const _ClientProfile({required this.client});

  final ClientDetail client;

  @override
  Widget build(BuildContext context) {
    final demographics = [
      if (client.age != null) '${client.age}세',
      if (client.gender?.isNotEmpty ?? false) client.gender!,
    ];
    final imageUrl = client.profileImageUrl?.trim();

    return Column(
      children: [
        _ProfileAvatar(imageUrl: imageUrl),
        const SizedBox(height: 12),
        Text(
          client.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1A2B49),
            fontFamily: 'GowunBatang',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (demographics.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            demographics.join(' / '),
            style: const TextStyle(
              color: Color(0xFF7D879C),
              fontFamily: 'GowunBatang',
              fontSize: 14,
            ),
          ),
        ],
        if (client.memberCode?.isNotEmpty ?? false) ...[
          const SizedBox(height: 8),
          Text(
            '인지번호 ${client.memberCode}',
            style: const TextStyle(
              color: Color(0xFF7D879C),
              fontFamily: 'GowunBatang',
              fontSize: 13,
            ),
          ),
        ],
        if (client.cognitiveStage?.isNotEmpty ?? false) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEFC),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              client.cognitiveStage!,
              style: const TextStyle(
                color: Color(0xFF8E89D9),
                fontFamily: 'GowunBatang',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: 84,
          height: 84,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => const CircleAvatar(
    radius: 42,
    backgroundColor: Color(0xFFFFF0EC),
    child: Icon(Icons.person, color: Color(0xFFFF6B53), size: 42),
  );
}

class _ClientVisitCard extends StatelessWidget {
  const _ClientVisitCard({required this.client});

  final ClientDetail client;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAEFF2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '최근 방문',
              style: TextStyle(
                color: Color(0xFF7D879C),
                fontFamily: 'GowunBatang',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            _formatDate(client.lastVisitAt),
            style: const TextStyle(
              color: Color(0xFF1A2B49),
              fontFamily: 'GowunBatang',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({required this.appointment});

  final AppointmentOut? appointment;

  @override
  Widget build(BuildContext context) {
    final detail = appointment;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF52A87B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A52A87B),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '다음 예정 상담',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'GowunBatang',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail == null
                ? '예정된 상담이 없습니다.'
                : _formatAppointment(detail.scheduledAt),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'GowunBatang',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (detail?.purpose?.isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            Text(
              detail!.purpose!,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'GowunBatang',
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final SessionBrief session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = session.title?.trim();
    final thumbnailUrl = session.thumbnailUrl?.trim();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFEAEFF2)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x041A2B49),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _SessionThumbnail(imageUrl: thumbnailUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title == null || title.isEmpty ? '상담 세션' : title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A2B49),
                        fontFamily: 'GowunBatang',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDate(session.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF7D879C),
                        fontFamily: 'GowunBatang',
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _sessionStatusLabel(session.status),
                      style: const TextStyle(
                        color: Color(0xFF52A87B),
                        fontFamily: 'GowunBatang',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF7D879C)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionThumbnail extends StatelessWidget {
  const _SessionThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          ApiService().resolveUrl(imageUrl!),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: const Color(0xFFFFF0EC),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.event_note, color: Color(0xFFFF6B53)),
  );
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1A2B49),
              fontFamily: 'GowunBatang',
              fontSize: 14,
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
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return '날짜 정보 없음';
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.'
      '${date.day.toString().padLeft(2, '0')}';
}

String _formatAppointment(DateTime date) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final period = date.hour < 12 ? '오전' : '오후';
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]}) '
      '$period $hour:$minute';
}

String _sessionStatusLabel(String status) {
  switch (status) {
    case 'completed':
      return '완료';
    case 'recording':
      return '진행 중';
    case 'pending':
      return '대기 중';
    case 'failed':
      return '실패';
    default:
      return status;
  }
}

class _CounselorBottomNavigation extends StatelessWidget {
  const _CounselorBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEFF2))),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavigationItem(
            label: '홈',
            icon: Icons.home_outlined,
            route: PrototypeRoutes.dashboard,
          ),
          _NavigationItem(
            label: '면담자',
            icon: Icons.people_outline,
            route: PrototypeRoutes.clientList,
            selected: true,
          ),
          _NavigationItem(
            label: '달력',
            icon: Icons.calendar_month_outlined,
            route: PrototypeRoutes.calendar,
          ),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final String route;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFFF6B53) : const Color(0xFF7D879C);
    return InkWell(
      onTap: () =>
          openPrototypeRoute(context, route, transition: FlowTransition.fade),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontFamily: 'GowunBatang',
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
