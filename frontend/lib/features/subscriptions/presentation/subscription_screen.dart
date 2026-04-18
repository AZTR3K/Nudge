import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/core/theme/app_colors.dart';
import 'package:nudge/core/widgets/payment_card.dart';
import 'package:nudge/features/subscriptions/providers/subscription_provider.dart';
import 'package:nudge/features/subscriptions/presentation/widgets/payment_action_sheets.dart'; // IMPORT ADDED

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Active Subscriptions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: subscriptionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return const Center(
              child: Text(
                'No active subscriptions.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: subscriptions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sub = subscriptions[index];
              final dueDate = DateTime.parse(sub['due_date']);
              final isOverdue = dueDate.isBefore(
                DateTime.now().subtract(const Duration(days: 1)),
              );

              final monthStr = [
                "Jan",
                "Feb",
                "Mar",
                "Apr",
                "May",
                "Jun",
                "Jul",
                "Aug",
                "Sep",
                "Oct",
                "Nov",
                "Dec",
              ][dueDate.month - 1];
              final formattedDate =
                  "$monthStr ${dueDate.day.toString().padLeft(2, '0')}";

              final dbStatus = sub['status'] ?? 'Pending';
              PaymentStatus paymentStatus;
              String subtitleText;

              if (dbStatus == 'Paid') {
                paymentStatus = PaymentStatus.paid;
                subtitleText = 'Paid • $formattedDate';
              } else if (dbStatus == 'Missed') {
                paymentStatus = PaymentStatus.missed;
                subtitleText = 'Failed • Action required';
              } else {
                if (isOverdue) {
                  paymentStatus = PaymentStatus.missed;
                  subtitleText = 'Overdue since $formattedDate';
                } else {
                  paymentStatus = PaymentStatus.pending;
                  subtitleText = 'Auto-renews $formattedDate';
                }
              }

              return PaymentCard(
                title: sub['service_name'],
                amount: (sub['amount'] as num).toStringAsFixed(2),
                subtitle: subtitleText,
                status: paymentStatus,
                icon: Icons.stars_outlined,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => EditPaymentSheet(sub: sub),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
