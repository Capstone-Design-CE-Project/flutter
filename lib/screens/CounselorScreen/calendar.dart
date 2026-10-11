import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../api/consultation_model.dart';
import '../../navigation/prototype_routes.dart';
import '../../widgets/device_clock.dart';

class CalendarV3 extends StatefulWidget {
  const CalendarV3({super.key});

  @override
  State<CalendarV3> createState() => _CalendarV3State();
}

class _CalendarV3State extends State<CalendarV3> {
  final ApiService _apiService = ApiService();
  late int _year;
  late int _month;
  DateTime? _selectedDate;
  late Future<CalendarMonthResponse> _monthFuture;
  late Future<List<AppointmentOut>> _upcomingFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    _monthFuture = _loadMonth();
    _upcomingFuture = _apiService.getUpcomingAppointments(limit: 1);
  }

  Future<CalendarMonthResponse> _loadMonth() {
    return _apiService.getCalendarMonth(year: _year, month: _month);
  }

  void _changeMonth(int amount) {
    final target = DateTime(_year, _month + amount);
    setState(() {
      _year = target.year;
      _month = target.month;
      _selectedDate = null;
      _monthFuture = _loadMonth();
    });
  }

  void _retryMonth() {
    setState(() => _monthFuture = _loadMonth());
  }

  void _retryUpcoming() {
    setState(
      () => _upcomingFuture = _apiService.getUpcomingAppointments(limit: 1),
    );
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
                  const DeviceClock(color: Color(0xFF1A2B49)),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '상담 일정',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF1A2B49),
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<CalendarMonthResponse>(
                future: _monthFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _CalendarMessage(
                      message: '달력을 불러오지 못했습니다.',
                      detail: snapshot.error.toString().replaceFirst(
                        'Exception: ',
                        '',
                      ),
                      actionLabel: '다시 시도',
                      onAction: _retryMonth,
                    );
                  }

                  final monthData = snapshot.data!;
                  final appointmentsByDate = {
                    for (final day in monthData.days) day.date: day,
                  };
                  return RefreshIndicator(
                    onRefresh: () async {
                      _retryMonth();
                      _retryUpcoming();
                      await _monthFuture;
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        _MonthHeader(
                          year: _year,
                          month: _month,
                          onPrevious: () => _changeMonth(-1),
                          onNext: () => _changeMonth(1),
                        ),
                        const SizedBox(height: 12),
                        const _WeekdayHeader(),
                        const SizedBox(height: 8),
                        _MonthGrid(
                          year: _year,
                          month: _month,
                          appointmentsByDate: appointmentsByDate,
                          selectedDate: _selectedDate,
                          onSelectDate: (date) =>
                              setState(() => _selectedDate = date),
                        ),
                        const SizedBox(height: 16),
                        _SelectedDateAppointments(
                          date: _selectedDate,
                          day: _selectedDate == null
                              ? null
                              : appointmentsByDate[_dateKey(_selectedDate!)],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '예정된 면담',
                          style: TextStyle(
                            color: Color(0xFF1A2B49),
                            fontFamily: 'GowunBatang',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<List<AppointmentOut>>(
                          future: _upcomingFuture,
                          builder: (context, upcomingSnapshot) {
                            if (upcomingSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (upcomingSnapshot.hasError) {
                              return _CalendarMessage(
                                message: '예정된 면담을 불러오지 못했습니다.',
                                actionLabel: '다시 시도',
                                onAction: _retryUpcoming,
                              );
                            }
                            final appointments =
                                upcomingSnapshot.data ??
                                const <AppointmentOut>[];
                            if (appointments.isEmpty) {
                              return const _CalendarMessage(
                                message: '예정된 면담이 없습니다.',
                              );
                            }
                            return _UpcomingAppointmentCard(
                              appointment: appointments.first,
                            );
                          },
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

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.year,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final int year;
  final int month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: '이전 달',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '$year년 $month월',
          style: const TextStyle(
            color: Color(0xFF1A2B49),
            fontFamily: 'GowunBatang',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          tooltip: '다음 달',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < _weekdays.length; index++)
          Expanded(
            child: Center(
              child: Text(
                _weekdays[index],
                style: TextStyle(
                  color: index == 6
                      ? const Color(0xFFE06358)
                      : const Color(0xFF526176),
                  fontFamily: 'GowunBatang',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.year,
    required this.month,
    required this.appointmentsByDate,
    required this.selectedDate,
    required this.onSelectDate,
  });

  final int year;
  final int month;
  final Map<String, CalendarDay> appointmentsByDate;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(year, month, 1).weekday - 1;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final cellCount = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    final today = DateUtils.dateOnly(DateTime.now());

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cellCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - firstWeekday + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(year, month, dayNumber);
        final key = _dateKey(date);
        final day = appointmentsByDate[key];
        final appointmentCount = day?.count ?? 0;
        final isSelected =
            selectedDate != null && DateUtils.isSameDay(selectedDate, date);
        final isToday = DateUtils.isSameDay(today, date);
        final weekday = index % 7;

        return Padding(
          padding: const EdgeInsets.all(2),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelectDate(date),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFE8E2) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B53)
                      : isToday
                      ? const Color(0xFFFFB3A6)
                      : const Color(0xFFEAEFF2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNumber',
                    style: TextStyle(
                      color: weekday == 6
                          ? const Color(0xFFE06358)
                          : const Color(0xFF1A2B49),
                      fontFamily: 'GowunBatang',
                      fontWeight: isToday || isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (appointmentCount > 0) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B53),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$appointmentCount건',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'GowunBatang',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SelectedDateAppointments extends StatelessWidget {
  const _SelectedDateAppointments({required this.date, required this.day});

  final DateTime? date;
  final CalendarDay? day;

  @override
  Widget build(BuildContext context) {
    if (date == null) {
      return const _CalendarMessage(message: '날짜를 선택하면 해당 날짜의 면담 일정이 표시됩니다.');
    }
    if (day == null || day!.appointments.isEmpty) {
      return _CalendarMessage(
        message: '${date!.month}월 ${date!.day}일에는 예정된 면담이 없습니다.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date!.month}월 ${date!.day}일 면담 · ${day!.count}건',
              style: const TextStyle(
                color: Color(0xFF1A2B49),
                fontFamily: 'GowunBatang',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (final appointment in day!.appointments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.event_outlined,
                  color: Color(0xFFFF6B53),
                ),
                title: Text(appointment.clientName ?? '내담자'),
                subtitle: Text(
                  '${_formatTime(appointment.scheduledAt)}'
                  '${appointment.purpose == null || appointment.purpose!.isEmpty ? '' : ' · ${appointment.purpose}'}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingAppointmentCard extends StatelessWidget {
  const _UpcomingAppointmentCard({required this.appointment});

  final AppointmentOut appointment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFF0ED),
          child: Icon(Icons.event_available_outlined, color: Color(0xFFFF6B53)),
        ),
        title: Text(appointment.clientName ?? '내담자'),
        subtitle: Text(
          '${_formatDateTime(appointment.scheduledAt)}'
          '${appointment.purpose == null || appointment.purpose!.isEmpty ? '' : ' · ${appointment.purpose}'}',
        ),
      ),
    );
  }
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _formatTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final period = local.hour < 12 ? '오전' : '오후';
  return '$period $hour:${local.minute.toString().padLeft(2, '0')}';
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  return '${local.year}년 ${local.month}월 ${local.day}일 ${_formatTime(local)}';
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
            _NavigationItem(
              icon: Icons.home_outlined,
              label: '홈',
              route: PrototypeRoutes.dashboard,
            ),
            _NavigationItem(
              icon: Icons.people_outline,
              label: '면담자',
              route: PrototypeRoutes.clientList,
            ),
            const _NavigationItem(
              icon: Icons.calendar_month_outlined,
              label: '달력',
              selected: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
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

class _CalendarMessage extends StatelessWidget {
  const _CalendarMessage({
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
