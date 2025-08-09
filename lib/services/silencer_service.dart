import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import '../models/schedule.dart';

class SilencerService {
  /// schedules device to go silent at the start time of the schedule (Android only)
  static Future<void> scheduleSilenceForSchedule(
    Schedule schedule, {
    BuildContext? context,
  }) async {
    if (!Platform.isAndroid) return;
    final dndGranted = await PermissionHandler.permissionsGranted;
    if (dndGranted != true) {
      await PermissionHandler.openDoNotDisturbSetting();
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please grant Do Not Disturb access for silent mode to work.',
            ),
          ),
        );
      }
      return;
    }
    final now = DateTime.now();
    final duration = schedule.startDateTime.difference(now);
    if (duration.isNegative) {
      // start time is in the past, do nothing
      return;
    }
    // schedule the device to go silent at the exact start time
    Future.delayed(duration, () async {
      await SoundMode.setSoundMode(RingerModeStatus.silent);
    });
  }
}
