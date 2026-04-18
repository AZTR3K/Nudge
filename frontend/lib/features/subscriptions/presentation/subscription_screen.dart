import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/core/theme/app_colors.dart';
import 'package:nudge/core/widgets/payment_card.dart';
import 'package:nudge/features/subscriptions/providers/subscription_provider.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch your real database stream!
    final subscriptionsAsync = ref.watch(subscriptionsFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Subscriptions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: subscriptionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
              final isOverdue = dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

              final monthStr = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][dueDate.month - 1];
              final formattedDate = "$monthStr ${dueDate.day}";

              // FIX: Replaced dueDate with subtitle, and added the status parameter
              return PaymentCard(
                title: sub['service_name'],
                amount: (sub['amount'] as num).toStringAsFixed(2),
                subtitle: isOverdue ? 'Overdue since $formattedDate' : 'Auto-renews $formattedDate',
                status: isOverdue ? PaymentStatus.missed : PaymentStatus.paid,
                icon: Icons.stars_outlined, // A nice distinct icon for the Subscriptions tab
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
