import 'package:flutter/material.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Water Bill', style: theme.textTheme.titleMedium),
            subtitle: const Text('Remind me 3 days before due date'),
            value: true,
            activeColor: theme.primaryColor,
            onChanged: (bool value) {},
            secondary: const Icon(Icons.water_drop_outlined),
          ),
          const Divider(),
          SwitchListTile(
            title: Text('Car Insurance', style: theme.textTheme.titleMedium),
            subtitle: const Text('Remind me 1 week before due date'),
            value: false,
            activeColor: theme.primaryColor,
            onChanged: (bool value) {},
            secondary: const Icon(Icons.directions_car_outlined),
          ),
        ],
      ),
    );
  }
}
