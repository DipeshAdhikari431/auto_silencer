import 'package:auto_silencer/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/notification_service.dart';
import 'l10n/app_localizations.dart';
import 'l10n/my_app_locale_changer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  // Request notification permissions
  await _requestNotificationPermissions();
  // Request exact alarms permission on Android
  final androidPlugin = NotificationService.notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await androidPlugin?.requestExactAlarmsPermission();
  runApp(const MyApp());
}

Future<void> _requestNotificationPermissions() async {
  // iOS
  final iosPlugin = NotificationService.notificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();
  await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  // macOS
  final macPlugin = NotificationService.notificationsPlugin
      .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin
      >();
  await macPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  // Android 13+
  final androidPlugin = NotificationService.notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await androidPlugin?.requestNotificationsPermission();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyAppLocaleChanger(
      changeLocale: _changeLocale,
      child: MaterialApp(
        locale: _locale,
        supportedLocales: const [Locale('en'), Locale('fr')],
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
