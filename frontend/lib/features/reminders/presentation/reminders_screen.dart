import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge/core/theme/app_colors.dart';
import 'package:nudge/features/subscriptions/providers/subscription_provider.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool _isMuted = false;

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(subscriptionsFutureProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'REMINDERS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: subscriptionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (subscriptions) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Mute All Notifications Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_paused,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mute All Notifications',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Temporarily pause all reminder alerts.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isMuted,
                      onChanged: (val) => setState(() => _isMuted = val),
                      // FIX: Updated activeColor to activeThumbColor to satisfy linter
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primaryDim.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Tabs
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Upcoming',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Text(
                    'History',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (subscriptions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("No upcoming reminders."),
                  ),
                ),

              // Dynamic Reminder Cards
              ...subscriptions.map((sub) {
                final dueDate = DateTime.parse(sub['due_date']);
                final now = DateTime.now();
                // Strip the time to calculate strict day differences
                final difference = DateTime(
                  dueDate.year,
                  dueDate.month,
                  dueDate.day,
                ).difference(DateTime(now.year, now.month, now.day)).inDays;

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

                String dateLabel;
                if (difference == 0) {
                  dateLabel = "Today, 09:00 AM";
                } else if (difference == 1) {
                  dateLabel = "Tomorrow, 09:00 AM";
                } else if (difference == -1) {
                  dateLabel = "Yesterday, 09:00 AM";
                } else {
                  dateLabel =
                      "$monthStr ${dueDate.day.toString().padLeft(2, '0')}, 09:00 AM";
                }

                String statusText;
                IconData statusIcon;
                Color statusColor;

                // Adjust logic and styling based on whether it is overdue or upcoming
                if (difference < 0) {
                  statusText = "Overdue by ${difference.abs()} days.";
                  statusIcon = Icons.error_outline;
                  statusColor = AppColors.error;
                } else if (difference == 0) {
                  statusText = "Due today. Prepare for deduction.";
                  statusIcon = Icons.info_outline;
                  statusColor = AppColors.primary;
                } else {
                  statusText = "Due in $difference days. Auto-pay is active.";
                  statusIcon = Icons.check_circle_outline;
                  statusColor = AppColors.primaryDim;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ReminderCard(
                    title: sub['service_name'],
                    amount: (sub['amount'] as num).toStringAsFixed(2),
                    dateLabel: dateLabel,
                    statusText: statusText,
                    statusIcon: statusIcon,
                    statusColor: statusColor,
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

class ReminderCard extends StatelessWidget {
  final String title;
  final String amount;
  final String dateLabel;
  final String statusText;
  final IconData statusIcon;
  final Color statusColor;

  const ReminderCard({
    super.key,
    required this.title,
    required this.amount,
    required this.dateLabel,
    required this.statusText,
    required this.statusIcon,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Accent Glow Line
            Container(width: 4, color: statusColor),

            // Main Card Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title & Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Rs $amount',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Status Subtitle
                    Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            statusText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons (Snooze / Edit)
                    Row(
                      children: [
                        _buildActionButton(Icons.snooze),
                        const SizedBox(width: 12),
                        _buildActionButton(Icons.edit_outlined),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
      ),
    );
  }
}
