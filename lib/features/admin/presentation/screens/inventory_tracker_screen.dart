import 'package:flutter/material.dart';

class InventoryTrackerScreen extends StatelessWidget {
  const InventoryTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Storage: 120 tonnes (60% of 200t capacity)'),
            const Text('Processing: 45 tonnes'),
            const Text('Ready for Sale: 35 tonnes'),
            const SizedBox(height: 16),
            const Text('INVENTORY BY TYPE'),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('Dry Stalks: 50t stock | 20t processing | 5% shrinkage'),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('Manure: 40t stock | 15t processing | 10% shrinkage'),
            ),
            const SizedBox(height: 16),
            const Text('RECENT DELIVERIES'),
            const Text('2:30 PM - Green Hill Farm - Dry Stalks - 450 kg - ★★★★'),
            const Text('1:15 PM - Sunrise Farm - Manure - 300 kg - ★★★'),
            TextButton(
              onPressed: () {},
              child: const Text('VIEW ALL'),
            ),
          ],
        ),
      ),
    );
  }
}
