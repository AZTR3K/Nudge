import 'package:flutter/material.dart';
import 'package:nudge/core/theme/app_colors.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Water Bill', style: theme.textTheme.titleMedium),
            subtitle: const Text('Remind me 3 days before due date'),
            value: true,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryDim.withValues(alpha: 0.5),
            onChanged: (bool value) {},
            secondary: const Icon(
              Icons.water_drop_outlined,
              color: AppColors.primary,
            ),
          ),
          const Divider(color: AppColors.outlineVariant),
          SwitchListTile(
            title: Text('Car Insurance', style: theme.textTheme.titleMedium),
            subtitle: const Text('Remind me 1 week before due date'),
            value: false,
            activeThumbColor: AppColors.primary,
            onChanged: (bool value) {},
            secondary: const Icon(
              Icons.directions_car_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
