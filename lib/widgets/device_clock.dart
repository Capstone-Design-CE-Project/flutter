import 'dart:async';

import 'package:flutter/material.dart';

class DeviceClock extends StatefulWidget {
  const DeviceClock({
    super.key,
    this.color = Colors.black,
    this.fontSize = 15,
    this.textAlign = TextAlign.left,
  });

  final Color color;
  final double fontSize;
  final TextAlign textAlign;

  @override
  State<DeviceClock> createState() => _DeviceClockState();
}

class _DeviceClockState extends State<DeviceClock> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNextMinute();
  }

  void _scheduleNextMinute() {
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );

    _timer = Timer(nextMinute.difference(now), () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _scheduleNextMinute();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      TimeOfDay.fromDateTime(_now).format(context),
      textAlign: widget.textAlign,
      style: TextStyle(
        color: widget.color,
        fontFamily: 'GowunBatang',
        fontSize: widget.fontSize,
        height: 1,
      ),
    );
  }
}
