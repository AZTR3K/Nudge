import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PaymentStatus { paid, missed, pending }

class PaymentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final PaymentStatus status;
  final IconData icon;
  final VoidCallback onTap;

  const PaymentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.status = PaymentStatus.pending,
    this.icon = Icons.receipt_long,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dynamic state variables
    Color statusColor;
    Color bgColor = AppColors.surfaceContainerLow;
    Color iconColor = AppColors.onSurface;
    Color subtitleColor = AppColors.onSurfaceVariant;
    IconData statusIcon;
    String statusText;
    bool hasLeftAccent = false;

    // Apply specific styles based on the status
    switch (status) {
      case PaymentStatus.paid:
        statusColor = AppColors.primary;
        statusIcon = Icons.check_circle;
        statusText = 'PAID';
        break;
      case PaymentStatus.missed:
        statusColor = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.05); // Subtle red tint
        iconColor = AppColors.error;
        subtitleColor = AppColors.error;
        statusIcon = Icons.error;
        statusText = 'MISSED';
        hasLeftAccent = true; // Trigger the red left border
        break;
      case PaymentStatus.pending:
        statusColor = const Color(0xFFF59E0B); // Amber/Warning color
        statusIcon = Icons.schedule;
        statusText = 'PENDING';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          // ClipRRect ensures the left accent border respects the rounded corners
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Border Accent (Only visible if missed)
                  if (hasLeftAccent) Container(width: 4, color: AppColors.error),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icon Circle
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHighest,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: status == PaymentStatus.missed
                                    ? AppColors.error.withValues(alpha: 0.2)
                                    : AppColors.outlineVariant.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(icon, color: iconColor),
                          ),
                          const SizedBox(width: 16),

                          // Title and Subtitle Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: subtitleColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Amount and Status Pill
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Rs $amount',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.2),
                                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(statusIcon, size: 10, color: statusColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      statusText,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
