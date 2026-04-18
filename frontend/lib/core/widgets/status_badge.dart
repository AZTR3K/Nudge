import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PaymentStatus { paid, upcoming, overdue }

class StatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case PaymentStatus.paid:
        bgColor = AppColors.successGreen.withOpacity(0.2);
        textColor = AppColors.successGreen;
        label = 'Paid';
        break;
      case PaymentStatus.upcoming:
        bgColor = AppColors.warningOrange.withOpacity(0.2);
        textColor = AppColors.warningOrange;
        label = 'Upcoming';
        break;
      case PaymentStatus.overdue:
        bgColor = AppColors.dangerRed.withOpacity(0.2);
        textColor = AppColors.dangerRed;
        label = 'Overdue';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
