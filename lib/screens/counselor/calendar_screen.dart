import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _Appointment {
  final String name;
  final int day;
  final Color color;
  _Appointment(this.name, this.day, this.color);
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DateTime _now = DateTime.now();
  late List<_Appointment> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = [
      _Appointment("김노인", _now.day, const Color(0xFF0EA5E9)),
      _Appointment("이순자", _now.day + 1, const Color(0xFF38BDF8)),
      _Appointment("박동수", _now.day + 3, const Color(0xFF0284C7)),
      _Appointment("최말년", _now.day + 5, const Color(0xFF075985)),
    ];
  }

  Widget _buildCalendar() {
    int daysInMonth = DateUtils.getDaysInMonth(_now.year, _now.month);
    int firstWeekday = DateTime(_now.year, _now.month, 1).weekday;
    int firstDayOffset = firstWeekday == 7 ? 0 : firstWeekday;

    List<Widget> dayWidgets = [];
    final List<String> weekDays = ["일", "월", "화", "수", "목", "금", "토"];

    for (var w in weekDays) {
      dayWidgets.add(
        Center(
          child: Text(w, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    }

    for (int i = 0; i < firstDayOffset; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int d = 1; d <= daysInMonth; d++) {
      var appts = _appointments.where((a) => a.day == d).toList();
      dayWidgets.add(
        Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text("$d", style: const TextStyle(fontSize: 12)),
              ),
              if (appts.isNotEmpty)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(2),
                    children: appts
                        .map(
                          (a) => Container(
                            margin: const EdgeInsets.all(1),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: a.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              a.name,
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 7,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.65,
      children: dayWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${_now.year}년 ${_now.month}월 일정")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              color: Colors.grey.withOpacity(0.05),
              child: _buildCalendar(),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "상담 예약 현황",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appt = _appointments[index];
                return ListTile(
                  title: Text(appt.name),
                  subtitle: Text("${_now.year}년 ${_now.month}월 ${appt.day}일"),
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: appt.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
