import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class FarmerHomeScreen extends StatelessWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back, Green Hill Farm'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all()),
              child: Column(
                children: const [
                  Text('Total Balance: KSh 12,450'),
                  SizedBox(height: 8),
                  Text('Withdraw'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  NavigationService.push('/farmer/sell/waste-type');
                },
                child: const Text('SELL MY WASTE'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Recent Activity'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('✓ Dry Stalks - 150 kg - KSh 750 - Yesterday'),
            ),
            TextButton(
              onPressed: () {
                NavigationService.push('/farmer/earnings');
              },
              child: const Text('View All History'),
            ),
          ],
        ),
      ),
    );
  }
}
