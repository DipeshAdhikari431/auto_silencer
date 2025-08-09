import 'package:auto_silencer/l10n/app_localizations.dart';
import 'package:auto_silencer/main.dart';
import 'package:auto_silencer/services/timezone_service.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:async';

class GlobalTimeScreen extends StatefulWidget {
  const GlobalTimeScreen({super.key});

  @override
  State<GlobalTimeScreen> createState() => _GlobalTimeScreenState();
}

class _GlobalTimeScreenState extends State<GlobalTimeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // re-initialize timezone in case device timezone has changed
    Future.microtask(() async {
      await TimeZoneService.initialize();
      setState(() {});
    });
  }

  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  final List<Map<String, String>> _cities = [
    {'name': 'Your Location', 'tz': ''},
    {'name': 'New York', 'tz': 'America/New_York'},
    {'name': 'London', 'tz': 'Europe/London'},
    {'name': 'Paris', 'tz': 'Europe/Paris'},
    {'name': 'Tokyo', 'tz': 'Asia/Tokyo'},
    {'name': 'Sydney', 'tz': 'Australia/Sydney'},
    {'name': 'Beijing', 'tz': 'Asia/Shanghai'},
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.globalTime)),
      body: ListView.builder(
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          final tz.TZDateTime cityTime = city['tz'] == ''
              ? tz.TZDateTime.from(_now, tz.local)
              : tz.TZDateTime.from(_now, tz.getLocation(city['tz']!));
          final String zoneName = city['tz'] == ''
              ? tz.local.name
              : city['tz']!;
          return ListTile(
            title: Text(city['name']!),
            subtitle: Text(
              '${cityTime.year}-${cityTime.month.toString().padLeft(2, '0')}-${cityTime.day.toString().padLeft(2, '0')} '
              '${cityTime.hour.toString().padLeft(2, '0')}:${cityTime.minute.toString().padLeft(2, '0')}:${cityTime.second.toString().padLeft(2, '0')} ($zoneName)',
            ),
          );
        },
      ),
    );
  }
}
