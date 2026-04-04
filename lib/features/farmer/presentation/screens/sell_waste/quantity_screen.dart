import 'package:flutter/material.dart';
import '../../../../../../core/services/navigation_service.dart';

class QuantityScreen extends StatelessWidget {
  const QuantityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estimate Quantity')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('HOW MUCH DO YOU HAVE?'),
            const SizedBox(height: 16),
            const ListTile(title: Text('Small (1-5 bags ≈ 10-50 kg)')),
            const ListTile(title: Text('Medium (6-20 bags ≈ 60-200 kg)')),
            const ListTile(title: Text('Large (21-50 bags ≈ 210-500 kg)')),
            const ListTile(title: Text('Truckload (51+ bags ≈ 510+ kg)')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NavigationService.push('/farmer/sell/photo');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
