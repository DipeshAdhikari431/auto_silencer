import 'package:flutter/material.dart';

/// InheritedWidget to allow locale change from anywhere in the widget tree
class MyAppLocaleChanger extends InheritedWidget {
  final void Function(Locale) changeLocale;
  const MyAppLocaleChanger({
    required this.changeLocale,
    required super.child,
    super.key,
  });

  static MyAppLocaleChanger? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyAppLocaleChanger>();
  }

  @override
  bool updateShouldNotify(MyAppLocaleChanger oldWidget) => false;
}
