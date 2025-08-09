import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/schedule.dart';

class SharedPreferencesService {
  static const String schedulesKey = 'schedules';

  Future<List<Schedule>> loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(schedulesKey);
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => Schedule.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> saveSchedules(List<Schedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = schedules.map((e) => e.toJson()).toList();
    await prefs.setString(schedulesKey, jsonEncode(jsonList));
  }
}
