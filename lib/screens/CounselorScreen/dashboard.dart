import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../api/consultation_model.dart';
import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final ApiService _apiService = ApiService();
  late Future<DashboardResponse> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _apiService.getDashboard();
  }

  void _retry() {
    setState(() => _dashboardFuture = _apiService.getDashboard());
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
                  DeviceClock(color: const Color(0xFF1A2B49)),
                  const Spacer(),
                  const Icon(Icons.signal_cellular_alt, size: 18),
                  const SizedBox(width: 6),
                  const Icon(Icons.wifi, size: 18),
                  const SizedBox(width: 6),
                  const Icon(Icons.battery_full, size: 20),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<DashboardResponse>(
                future: _dashboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _DashboardMessage(
                      message: '대시보드를 불러오지 못했습니다.',
                      detail: snapshot.error.toString().replaceFirst(
                        'Exception: ',
                        '',
                      ),
                      actionLabel: '다시 시도',
                      onAction: _retry,
                    );
                  }

                  final dashboard = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: () async {
                      _retry();
                      await _dashboardFuture;
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '기억의 조각',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: const Color(0xFF1A2B49),
                                      fontSize: 24,
                                    ),
                              ),
                            ),
                            const CircleAvatar(
                              backgroundColor: Color(0xFFFFE8E2),
                              child: Icon(
                                Icons.person_outline,
                                color: Color(0xFFFF6B53),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _GreetingCard(dashboard: dashboard),
                        const SizedBox(height: 20),
                        Text(
                          '오늘의 업무 현황',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF1A2B49),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _DashboardActions(dashboard: dashboard),
                        const SizedBox(height: 16),
                        _NextAppointmentCard(
                          appointment: dashboard.nextAppointment,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const _CounselorBottomNavigation(),
          ],
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.dashboard});

  final DashboardResponse dashboard;

  @override
  Widget build(BuildContext context) {
    final todayCount = dashboard.todayAppointmentCount;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B53), Color(0xFFFF8E7C)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AFF6B53),
            offset: Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dashboard.greeting.isNotEmpty
                ? dashboard.greeting
                : '${dashboard.counselorName} 상담사님',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'GowunBatang',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            todayCount == 0
                ? '오늘 예정된 상담은 없습니다.'
                : '오늘 예정된 상담은 총 $todayCount건입니다.',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'GowunBatang',
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          FlowAction(
            route: PrototypeRoutes.recordingClientList,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                '+  새 상담 시작하기',
                style: TextStyle(
                  color: Color(0xFFFF6B53),
                  fontFamily: 'GowunBatang',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardActions extends StatelessWidget {
  const _DashboardActions({required this.dashboard});

  final DashboardResponse dashboard;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _ActionCard(
          icon: Icons.people_outline,
          label: '환자 명단',
          color: const Color(0xFF8E89D9),
          background: const Color(0xFFF0EEFC),
          route: PrototypeRoutes.clientList,
        ),
        _ActionCard(
          icon: Icons.calendar_month_outlined,
          label: '일정 보기',
          value: dashboard.nextAppointment == null
              ? '예정된 상담 없음'
              : _formatDateTime(dashboard.nextAppointment!.scheduledAt),
          color: const Color(0xFF52A87B),
          background: const Color(0xFFE8F5EE),
          route: PrototypeRoutes.calendar,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    this.value,
    this.route,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color color;
  final Color background;
  final String? route;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            foregroundColor: Colors.white,
            child: Icon(icon, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF344B6E),
                  fontFamily: 'GowunBatang',
                  fontSize: 14,
                ),
              ),
              if (value != null) ...[
                const SizedBox(height: 4),
                Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1A2B49),
                    fontFamily: 'GowunBatang',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (route == null) return card;
    return FlowAction(route: route!, child: card);
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({required this.appointment});

  final AppointmentOut? appointment;

  @override
  Widget build(BuildContext context) {
    final name = appointment?.clientName;
    final details = appointment == null
        ? '등록된 예약 일정이 없습니다.'
        : [
            if (name != null && name.isNotEmpty) name,
            _formatDateTime(appointment!.scheduledAt),
            if (appointment!.purpose != null &&
                appointment!.purpose!.isNotEmpty)
              appointment!.purpose!,
          ].join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFFFF0ED),
              child: Icon(
                Icons.event_available_outlined,
                color: Color(0xFFFF6B53),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '다음 상담 약속',
                    style: TextStyle(
                      color: Color(0xFF526176),
                      fontFamily: 'GowunBatang',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    details,
                    style: const TextStyle(
                      color: Color(0xFF1A2B49),
                      fontFamily: 'GowunBatang',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final period = local.hour < 12 ? '오전' : '오후';
  return '${local.month}월 ${local.day}일 $period $hour:${local.minute.toString().padLeft(2, '0')}';
}

class _CounselorBottomNavigation extends StatelessWidget {
  const _CounselorBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEFF2))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const _BottomNavigationItem(
              icon: Icons.home_outlined,
              label: '홈',
              selected: true,
            ),
            _BottomNavigationItem(
              icon: Icons.people_outline,
              label: '면담자',
              route: PrototypeRoutes.clientList,
            ),
            _BottomNavigationItem(
              icon: Icons.calendar_month_outlined,
              label: '달력',
              route: PrototypeRoutes.calendar,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavigationItem extends StatelessWidget {
  const _BottomNavigationItem({
    required this.icon,
    required this.label,
    this.route,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final String? route;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFFFF6B53) : const Color(0xFF7D879C);
    final item = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontFamily: 'GowunBatang',
            fontSize: 13,
          ),
        ),
      ],
    );

    if (route == null) return item;
    return FlowAction(
      route: route!,
      transition: FlowTransition.fade,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: item,
      ),
    );
  }
}

class _DashboardMessage extends StatelessWidget {
  const _DashboardMessage({
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
            Text(message, textAlign: TextAlign.center),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(detail!, textAlign: TextAlign.center),
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
