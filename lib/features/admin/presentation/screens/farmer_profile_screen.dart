import 'package:flutter/material.dart';

class FarmerProfileScreen extends StatelessWidget {
  const FarmerProfileScreen({super.key, required String farmerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Green Hill Farm'),
            const Text('John Mwangi'),
            const Text('Kiambu Road, Nairobi'),
            const Text('Member since: Jan 2024'),
            const SizedBox(height: 16),
            const Text('Total Supplied: 2,450 kg'),
            const Text('Total Earned: KSh 12,250'),
            const Text('Avg Quality Rating: 4.2 ★'),
            const SizedBox(height: 16),
            const Text('TRANSACTION HISTORY'),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('Apr 2 - Dry Stalks - 450 kg - KSh 2,250 - ★★★★'),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all()),
              child: const Text('Mar 28 - Manure - 300 kg - KSh 900 - ★★★'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('CALL')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () {}, child: const Text('SMS')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () {}, child: const Text('BLOCK FARMER')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
