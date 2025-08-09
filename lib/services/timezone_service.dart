import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class TimeZoneService {
  static Future<void> initialize() async {
    tzdata.initializeTimeZones();
    String timeZoneName;
    try {
      timeZoneName = await FlutterTimezone.getLocalTimezone();
      print('Device IANA timezone: $timeZoneName');
      print(tz.getLocation(timeZoneName));
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print('Failed to get/set device timezone, falling back to UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    print(
      'tz.local: ${tz.local.name}, offset: ${tz.local.currentTimeZone.offset}',
    );
  }

  static tz.TZDateTime toLocal(DateTime dt) {
    return tz.TZDateTime.from(dt, tz.local);
  }
}
