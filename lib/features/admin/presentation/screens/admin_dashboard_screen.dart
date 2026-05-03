import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard - Recycle Farm')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today: April 4, 2024'),
            const SizedBox(height: 16),
            // KPI Cards
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('Available Waste: 45 tonnes'),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('Today\'s Collection: 67%'),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('Active Trucks: 3 of 5'),
            ),
            const SizedBox(height: 16),
            const Text('Supply Map'),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all()),
              child: const Center(child: Text('[Map with 12 farmer pins]')),
            ),
            const SizedBox(height: 16),
            const Text('URGENT PICKUPS (Waiting > 2 days)'),
            const Text('Green Hill Farm - Dry Stalks - 500 kg - Waiting 3 days'),
            const Text('Sunrise Farm - Manure - 300 kg - Waiting 2 days'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Assign Truck'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => NavigationService.go('/admin/inventory'),
                  child: const Text('Inventory'),
                ),
                TextButton(
                  onPressed: () => NavigationService.go('/admin/fleet'),
                  child: const Text('Fleet'),
                ),
                TextButton(
                  onPressed: () => NavigationService.go('/admin/pricing'),
                  child: const Text('Pricing'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
