import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class DriverRouteScreen extends StatelessWidget {
  const DriverRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Route")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Good morning, James'),
            const Text('Truck: KCA 123A | Capacity: 5 tonnes'),
            const SizedBox(height: 16),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all()),
              child: const Center(child: Text('[Route Map with 5 stops]')),
            ),
            const SizedBox(height: 16),
            const Text('NEXT PICKUP'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all()),
<<<<<<< HEAD
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
=======
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
>>>>>>> upstream/master
                  Text('Green Hill Farm'),
                  Text('Distance: 3.2 km'),
                  Text('Est. Waste: 500 kg'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Launch maps - just navigate to arrival
                  NavigationService.go('/driver/arrival');
                },
                child: const Text('START NAV'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('UPCOMING STOPS'),
            const Text('• Sunrise Farm - 300 kg'),
            const Text('• Valley View - 450 kg'),
            TextButton(
              onPressed: () {},
              child: const Text('VIEW FULL ROUTE'),
            ),
          ],
        ),
      ),
    );
  }
}
