import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/core/widgets/payment_card.dart';
import 'package:nudge/core/widgets/status_badge.dart';
import 'package:nudge/features/subscriptions/providers/subscription_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch our Supabase stream provider
    final subscriptionsAsync = ref.watch(subscriptionsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: false),
      body: subscriptionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (subscriptions) {
          // Calculate total amount dynamically
          double totalDue = 0;
          for (var sub in subscriptions) {
            totalDue += (sub['amount'] as num).toDouble();
          }

          return ListView(
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
                      'Total Subscriptions',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs ${totalDue.toStringAsFixed(2)}', // Switched to Rs
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
                "Your Bills",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Empty State
              if (subscriptions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      "No subscriptions yet. Click the + button to add one!",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),

              // Dynamic List of Payment Cards
              ...subscriptions.map((sub) {
                final dueDate = DateTime.parse(sub['due_date']);
                final isOverdue = dueDate.isBefore(
                  DateTime.now().subtract(const Duration(days: 1)),
                );

                // Format the date nicely (e.g., "2026-10-30")
                final formattedDate =
                    "${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: PaymentCard(
                    title: sub['service_name'],
                    amount: (sub['amount'] as num).toStringAsFixed(2),
                    dueDate: formattedDate,
                    status: isOverdue
                        ? PaymentStatus.overdue
                        : PaymentStatus.upcoming,
                    onTap: () {
                      // We will add the edit/delete functionality here later!
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
