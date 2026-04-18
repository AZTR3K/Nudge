import 'package:flutter/material.dart';
// Replace 'nudge' with your actual project name from pubspec.yaml
import 'package:nudge/core/theme/app_theme.dart';
import 'package:nudge/core/widgets/payment_card.dart';
import 'package:nudge/core/widgets/status_badge.dart';

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
      themeMode: ThemeMode.light,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            "Quick Summary",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Using our custom PaymentCard widgets
          PaymentCard(
            title: "Internet Subscription",
            amount: "59.99",
            dueDate: "Oct 24, 2026",
            status: PaymentStatus.upcoming,
            onTap: () => print("Clicked Internet"),
          ),
          const SizedBox(height: 12),

          PaymentCard(
            title: "Rent - October",
            amount: "1,200.00",
            dueDate: "Oct 01, 2026",
            status: PaymentStatus.paid,
            onTap: () => print("Clicked Rent"),
          ),
          const SizedBox(height: 12),

          PaymentCard(
            title: "Electric Bill",
            amount: "142.50",
            dueDate: "Sep 15, 2026",
            status: PaymentStatus.overdue,
            onTap: () => print("Clicked Electric"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
