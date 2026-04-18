import 'package:flutter/material.dart';
import 'package:nudge/core/widgets/payment_card.dart';
import 'package:nudge/core/widgets/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Monthly Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Due This Month',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$1,402.49',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Upcoming & Overdue",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          PaymentCard(
            title: "Electric Bill",
            amount: "142.50",
            dueDate: "Sep 15, 2026",
            status: PaymentStatus.overdue,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          PaymentCard(
            title: "Internet Subscription",
            amount: "59.99",
            dueDate: "Oct 24, 2026",
            status: PaymentStatus.upcoming,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
