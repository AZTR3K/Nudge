import 'package:flutter/material.dart';
import 'package:nudge/core/theme/app_colors.dart';
import 'package:nudge/core/widgets/payment_card.dart';
import 'package:nudge/core/widgets/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Using the text colors from our Ayu theme definitions
    final textPrimary = isDark
        ? AppColors.mirageTextPrimary
        : AppColors.lightTextPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _SummaryCard(
                label: 'Total Due',
                value: '\$202.49',
                // Using Ayu Mirage/Light surface colors with subtle danger accent
                bgColor: isDark
                    ? AppColors.mirageSurface
                    : AppColors.lightSurface,
                accentColor: AppColors.dangerRed,
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _SummaryCard(
                label: 'Paid This Month',
                value: '\$1,200.00',
                // Using Ayu Mirage/Light surface colors with subtle success accent
                bgColor: isDark
                    ? AppColors.mirageSurface
                    : AppColors.lightSurface,
                accentColor: AppColors.successGreen,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Upcoming Payments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          PaymentCard(
            title: 'Internet Subscription',
            amount: '59.99',
            dueDate: 'Oct 24, 2026',
            status: PaymentStatus.upcoming,
            onTap: () {}, // Fixed: Added missing onTap
          ),
          const SizedBox(height: 10),
          PaymentCard(
            title: 'Electric Bill',
            amount: '142.50',
            dueDate: 'Sep 15, 2026',
            status: PaymentStatus.overdue,
            onTap: () {}, // Fixed: Added missing onTap
          ),
          const SizedBox(height: 24),
          Text(
            'Recently Paid',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          PaymentCard(
            title: 'Rent — October',
            amount: '1,200.00',
            dueDate: 'Oct 01, 2026',
            status: PaymentStatus.paid,
            onTap: () {}, // Fixed: Added missing onTap
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color bgColor;
  final Color accentColor;
  final bool isDark;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.bgColor,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          // Adding a subtle border to match Ayu UI aesthetics
          border: Border.all(
            color: isDark ? AppColors.mirageDivider : AppColors.lightDivider,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.mirageTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
