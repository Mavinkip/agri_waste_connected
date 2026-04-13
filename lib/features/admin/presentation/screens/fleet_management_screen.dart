import 'package:flutter/material.dart';

class FleetManagementScreen extends StatelessWidget {
  const FleetManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fleet Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active: 3 | Idle: 1 | Maintenance: 1'),
            const SizedBox(height: 16),
            const Text('Fleet List'),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('KCA 123A - James - Active - 75% complete'),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('KCB 456B - Mary - Active - 50% complete'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('ASSIGN NEW ROUTE'),
            ),
          ],
        ),
      ),
    );
  }
}
