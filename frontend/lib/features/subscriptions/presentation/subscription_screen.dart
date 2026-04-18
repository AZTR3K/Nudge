import 'package:flutter/material.dart';
import 'package:nudge/core/widgets/payment_card.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Subscriptions'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return PaymentCard(
            title: "Netflix Premium",
            amount: "22.99",
            dueDate: "Oct 30", // Adjusted to short format for Luminous
            onTap: () {},
          );
        },
      ),
    );
  }
}
