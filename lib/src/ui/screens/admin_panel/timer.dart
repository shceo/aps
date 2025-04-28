import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aps/l10n/app_localizations.dart';

/// Виджет, который самостоятельно каждую минуту обновляет своё отображение.
class IstanbulClock extends StatefulWidget {
  const IstanbulClock({Key? key}) : super(key: key);

  @override
  State<IstanbulClock> createState() => _IstanbulClockState();
}

class _IstanbulClockState extends State<IstanbulClock> {
  late Timer _timer;
  DateTime _now = DateTime.now().toUtc().add(const Duration(hours: 3));

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now().toUtc().add(const Duration(hours: 3));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final formatted = DateFormat('dd.MM.yyyy | HH:mm').format(_now);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(loc.serverTimeLabel, style: const TextStyle(fontSize: 12)),
        Text(
          formatted,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
