import '../services/timezone_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;

import 'package:auto_silencer/l10n/app_localizations.dart';
import 'package:auto_silencer/l10n/my_app_locale_changer.dart';
import 'package:flutter/material.dart';
import '../services/silencer_service.dart';

import '../models/schedule.dart';
import '../services/notification_service.dart';
import '../services/shared_preferences_service.dart';
import '../widgets/add_edit_schedule_dialog.dart';
import 'global_time_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // re-initialize timezone in case device timezone has changed
    Future.microtask(() async {
      await TimeZoneService.initialize();
      setState(() {});
    });
  }

  // method to split schedules into upcoming schedules(including today)
  Map<String, List<Schedule>> _groupUpcomingSchedules(
    List<Schedule> schedules,
  ) {
    final now = DateTime.now();
    return _groupSchedulesByDate(
      schedules
          .where(
            (s) =>
                !s.endDateTime.isBefore(DateTime(now.year, now.month, now.day)),
          )
          .toList(),
    );
  }

  // method to split schedules into past schedules
  Map<String, List<Schedule>> _groupPastSchedules(List<Schedule> schedules) {
    final now = DateTime.now();
    return _groupSchedulesByDate(
      schedules
          .where(
            (s) =>
                s.endDateTime.isBefore(DateTime(now.year, now.month, now.day)),
          )
          .toList(),
    );
  }

  // grouping schedules by date (yyyy-MM-dd, so UI can show schedules in sections by day
  Map<String, List<Schedule>> _groupSchedulesByDate(List<Schedule> schedules) {
    Map<String, List<Schedule>> grouped = {};
    for (var schedule in schedules) {
      String dateKey =
          "${schedule.startDateTime.year}-${schedule.startDateTime.month.toString().padLeft(2, '0')}-${schedule.startDateTime.day.toString().padLeft(2, '0')}";
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(schedule);
    }
    // sorting the map by date ascending so todays schedules appear first in UI
    var sortedKeys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));
    Map<String, List<Schedule>> sortedGrouped = {
      for (var k in sortedKeys) k: grouped[k]!,
    };
    return sortedGrouped;
  }

  // method to format time as 12-hour with AM/PM, devices using 24 hour format will show hours in timepicker and timepicker UI is messy with that amount of hour values
  String _formatTime12Hour(tz.TZDateTime dt) {
    int hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    String minute = dt.minute.toString().padLeft(2, '0');
    String period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  List<Schedule> schedules = [];
  final SharedPreferencesService _prefsService = SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  // load schedueles from shared preferences
  Future<void> _loadSchedules() async {
    final loaded = await _prefsService.loadSchedules();
    setState(() {
      schedules = loaded;
    });
  }

  // save all schedules to shared prefs
  Future<void> _saveSchedules() async {
    await _prefsService.saveSchedules(schedules);
  }

  // add a new schedule
  void _addSchedule(Schedule schedule) {
    // Always store in UTC
    final utcSchedule = Schedule(
      schedule.startDateTime.toUtc(),
      schedule.endDateTime.toUtc(),
      title: schedule.title,
    );
    setState(() {
      schedules.add(utcSchedule);
    });
    _saveSchedules();
    // schedule notification
    final notifId = schedules.length - 1;
    NotificationService.scheduleNotification(
      id: notifId,
      title: utcSchedule.title ?? AppLocalizations.of(context).scheduleTitle,
      body:
          '${_formatTime12Hour(tz.TZDateTime.from(utcSchedule.startDateTime, tz.local))} - ${_formatTime12Hour(tz.TZDateTime.from(utcSchedule.endDateTime, tz.local))}',
      scheduledTime: utcSchedule.startDateTime,
    );
    _scheduleSilenceForSchedule(schedule);
  }

  // Schedules device to go silent at start and restore at end (Android only)
  void _scheduleSilenceForSchedule(Schedule schedule, {int? index}) async {
    await SilencerService.scheduleSilenceForSchedule(
      schedule,
      context: context,
    );
  }

  // update a schedule
  void _editSchedule(int index, Schedule schedule) {
    // Always store in UTC
    final utcSchedule = Schedule(
      schedule.startDateTime.toUtc(),
      schedule.endDateTime.toUtc(),
      title: schedule.title,
    );
    setState(() {
      schedules[index] = utcSchedule;
    });
    _saveSchedules();
    // cancel previous notification and schedule new one
    NotificationService.cancelNotification(index);
    NotificationService.scheduleNotification(
      id: index,
      title: utcSchedule.title ?? AppLocalizations.of(context).scheduleTitle,
      body:
          '${_formatTime12Hour(tz.TZDateTime.from(utcSchedule.startDateTime, tz.local))} - ${_formatTime12Hour(tz.TZDateTime.from(utcSchedule.endDateTime, tz.local))}',
      scheduledTime: utcSchedule.startDateTime,
    );

    _scheduleSilenceForSchedule(utcSchedule, index: index);
  }

  // delete a schedule
  void _deleteSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
    _saveSchedules();
    // cancel notification
    NotificationService.cancelNotification(index);

  }


  // show dialog to add or update schedule
  void _showAddOrEditScheduleDialog({Schedule? schedule, int? index}) async {
    final result = await showDialog<Schedule>(
      context: context,
      builder: (context) => AddEditScheduleDialog(schedule: schedule),
    );
    if (result != null) {
      if (index == null) {
        _addSchedule(result);
      } else {
        _editSchedule(index, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayKey =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final localizations = AppLocalizations.of(context);
    Locale currentLocale = Localizations.localeOf(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.appTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.access_time_outlined),
              tooltip: 'Global Time',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GlobalTimeScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
                // Reload schedules after returning from settings
                if (mounted) {
                  await _loadSchedules();
                }
              },
            ),
            // button to open dnd settings
            // IconButton(
            //   icon: const Icon(Icons.do_not_disturb_on),
            //   tooltip: 'Request DND Access',
            //   onPressed: () async {
            //     await PermissionHandler.openDoNotDisturbSetting();
            //     if (context.mounted) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(
            //           content: Text(
            //             'Please grant Do Not Disturb access for silent mode to work.',
            //           ),
            //         ),
            //       );
            //     }
            //   },
            // ),
            // button to test notification
            // IconButton(
            //   icon: const Icon(Icons.notifications_active),
            //   tooltip: 'Test Notification',
            //   onPressed: () async {
            //     // await PermissionHandler.openDoNotDisturbSetting();
            //     await NotificationService.showImmediateNotification();
            //     // await NotificationService.showScheduledNotification();
            //     if (context.mounted) {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('Test notification sent')),
            //       );
            //     }
            //   },
            // ),
            PopupMenuButton<Locale>(
              icon: const Icon(Icons.language),
              onSelected: (locale) {
                MyAppLocaleChanger.of(context)?.changeLocale(locale);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: const Locale('en'),
                  enabled: currentLocale.languageCode != 'en',
                  child: Text('English'),
                ),
                PopupMenuItem(
                  value: const Locale('fr'),
                  enabled: currentLocale.languageCode != 'fr',
                  child: Text('Français'),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: localizations.tabHome),
              Tab(text: localizations.tabPast),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Home Tab: today and future
            _buildScheduleList(
              _groupUpcomingSchedules(schedules),
              todayKey,
              emptyText: localizations.noUpcoming,
              todayLabel: localizations.today,
            ),
            // Past Tab: past events
            _buildScheduleList(
              _groupPastSchedules(schedules),
              todayKey,
              emptyText: localizations.noPast,
              todayLabel: localizations.today,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddOrEditScheduleDialog(),
          tooltip: localizations.addSchedule,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildScheduleList(
    Map<String, List<Schedule>> groupedSchedules,
    String todayKey, {
    String emptyText = 'No schedules yet.',
    String todayLabel = 'Today',
  }) {
    if (groupedSchedules.isEmpty) {
      return Center(child: Text(emptyText));
    }
    final entries = groupedSchedules.entries.toList();
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, sectionIdx) {
        final entry = entries[sectionIdx];
        final dateKey = entry.key;
        final isToday = dateKey == todayKey;
        final sectionTitle = isToday ? '$dateKey ($todayLabel)' : dateKey;
        final scheduleList = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sectionIdx > 0) const Divider(thickness: 1, height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Text(
                sectionTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...scheduleList.asMap().entries.map((schedEntry) {
              final sched = schedEntry.value;
              // Find the index in the original schedules list for edit/delete
              final origIndex = schedules.indexOf(sched);
              return ListTile(
                title: Text(
                  sched.title ?? AppLocalizations.of(context).scheduleTitle,
                ),
                subtitle: Text(
                  '${_formatTime12Hour(tz.TZDateTime.from(sched.startDateTime, tz.local))} - ${_formatTime12Hour(tz.TZDateTime.from(sched.endDateTime, tz.local))}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showAddOrEditScheduleDialog(
                        schedule: sched,
                        index: origIndex,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteSchedule(origIndex),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
