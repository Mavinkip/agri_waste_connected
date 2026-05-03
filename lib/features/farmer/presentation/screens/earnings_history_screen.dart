import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class EarningsHistoryScreen extends StatelessWidget {
  const EarningsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings History')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TOTAL EARNED: KSh 15,750'),
            const Text('This Month: KSh 3,250'),
            const SizedBox(height: 16),
            const Text('TODAY'),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('✓ Dry Stalks - 150 kg - KSh 750 - 2:30 PM'),
            ),
            const SizedBox(height: 8),
            const Text('YESTERDAY'),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('✓ Manure - 200 kg - KSh 600 - 11:20 AM'),
            ),
            TextButton(
              onPressed: () {
                NavigationService.pop();
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
