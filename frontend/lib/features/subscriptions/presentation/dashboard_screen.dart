import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/core/theme/app_colors.dart';
import 'package:nudge/core/widgets/payment_card.dart';
import 'package:nudge/features/subscriptions/presentation/history_screen.dart';
import 'package:nudge/features/subscriptions/providers/subscription_provider.dart';
import 'package:nudge/features/subscriptions/presentation/add_payment_screen.dart';
import 'package:nudge/features/reminders/presentation/reminders_screen.dart';
import 'package:nudge/features/subscriptions/presentation/widgets/payment_action_sheets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This now listens to a LIVE STREAM
    final subscriptionsAsync = ref.watch(subscriptionsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Nudge',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: AppColors.primary,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            ),
          ),
        ],
      ),
      body: subscriptionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (subscriptions) {
          // 1. Filter out PAID bills. Dashboard is for what's next.
          final activeBills = subscriptions.where((sub) {
            final rawStatus = sub['status']?.toString().trim() ?? 'Pending';
            return rawStatus != 'Paid';
          }).toList();

          // 2. Calculate Total Due
          double totalDue = 0;
          for (var sub in activeBills) {
            totalDue += (sub['amount'] as num).toDouble();
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            children: [
              // Summary Hero
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 32,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Due',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs ${totalDue.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        shadows: [
                          Shadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pending Items',
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${activeBills.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.analytics_outlined,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddPaymentScreen(),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryDim, AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.add_circle,
                              color: AppColors.onPrimaryFixed,
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add Bill',
                              style: TextStyle(
                                color: AppColors.onPrimaryFixed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.history,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'History',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                "Action Required",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              if (activeBills.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      "All caught up!",
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ),

              ...activeBills.map((sub) {
                final dueDate = DateTime.parse(sub['due_date']);
                final isOverdue = dueDate.isBefore(
                  DateTime.now().subtract(const Duration(days: 1)),
                );
                final formattedDate =
                    "${["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][dueDate.month - 1]} ${dueDate.day.toString().padLeft(2, '0')}";

                final String dbStatus = sub['status']?.toString() ?? 'Pending';

                // Final visual mapping
                PaymentStatus paymentStatus = PaymentStatus.pending;
                String subtitleText = 'Upcoming $formattedDate';

                if (dbStatus == 'Missed' || isOverdue) {
                  paymentStatus = PaymentStatus.missed;
                  subtitleText = 'Overdue $formattedDate';
                }

                return PaymentCard(
                  title: sub['service_name'],
                  amount: (sub['amount'] as num).toStringAsFixed(2),
                  subtitle: subtitleText,
                  status: paymentStatus,
                  icon: Icons.receipt_long,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => EditPaymentSheet(sub: sub),
                    );
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
