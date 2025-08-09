import 'dart:convert';
import 'dart:io';

import 'package:auto_silencer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/schedule.dart';
import '../services/shared_preferences_service.dart';
import '../services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Helper to format time for notification body
  String _formatTime12Hour(DateTime dt) {
    int hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    String minute = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  final SharedPreferencesService _prefsService = SharedPreferencesService();
  bool _isProcessing = false;

  Future<void> _exportSchedules() async {
    setState(() => _isProcessing = true);
    try {
      final schedules = await _prefsService.loadSchedules();
      final jsonStr = jsonEncode(schedules.map((s) => s.toJson()).toList());
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/schedules_export.json');
      await file.writeAsString(jsonStr);
      // Print the file path for debugging
      // ignore: avoid_print
      print('Exported schedules to: \\n  ${file.path}');
      if (context.mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.exportedToFile)));
      }
    } catch (e) {
      if (context.mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.exportFailed)));
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _importSchedules() async {
    setState(() => _isProcessing = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/schedules_export.json');
      final localizations = AppLocalizations.of(context);
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        final importedSchedules = jsonList
            .map((e) => Schedule.fromJson(e))
            .toList();

        // Load existing schedules and merge
        final existingSchedules = await _prefsService.loadSchedules();
        final mergedSchedules = List<Schedule>.from(existingSchedules)
          ..addAll(importedSchedules);
        await _prefsService.saveSchedules(mergedSchedules);

        // After saving, reload all schedules from shared prefs
        final allSchedules = await _prefsService.loadSchedules();
        await NotificationService.cancelAllNotifications();
        for (int i = 0; i < allSchedules.length; i++) {
          final sched = allSchedules[i];
          NotificationService.scheduleNotification(
            id: i,
            title: sched.title ?? localizations.scheduleTitle,
            body:
                '${_formatTime12Hour(tz.TZDateTime.from(sched.startDateTime, tz.local))} - ${_formatTime12Hour(tz.TZDateTime.from(sched.endDateTime, tz.local))}',
            scheduledTime: sched.startDateTime,
          );
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.importedFromFile)),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(localizations.noExportFile)));
        }
      }
    } catch (e) {
      if (context.mounted) {
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.importFailed)));
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.file_upload),
              label: Text(localizations.exportSchedules),
              onPressed: _isProcessing ? null : _exportSchedules,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.file_download),
              label: Text(localizations.importSchedules),
              onPressed: _isProcessing ? null : _importSchedules,
            ),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(top: 32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
