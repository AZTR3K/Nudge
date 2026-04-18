import 'package:flutter/material.dart';
import 'package:nudge/core/theme/app_theme.dart';
import 'package:nudge/core/widgets/main_navigation_cell.dart';

void main() {
  runApp(const SmartPaymentApp());
}

class SmartPaymentApp extends StatelessWidget {
  const SmartPaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nudge Payment Reminder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigationShell(),
    );
  }
}
