import 'package:flutter/material.dart';
import '../../../../../../core/services/navigation_service.dart';

class WasteTypeScreen extends StatelessWidget {
  const WasteTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Waste Type')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('WHAT ARE YOU SELLING?'),
            const SizedBox(height: 16),
            const ListTile(title: Text('Dry Stalks - KSh 5.00/kg')),
            const ListTile(title: Text('Animal Manure - KSh 3.00/kg')),
            const ListTile(title: Text('Husks & Shells - KSh 4.00/kg')),
            const ListTile(title: Text('Green Waste - KSh 2.50/kg')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NavigationService.push('/farmer/sell/quantity');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
