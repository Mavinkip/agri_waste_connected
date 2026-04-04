import 'package:flutter/material.dart';
import '../../../../../../core/services/navigation_service.dart';

class ConfirmLocationScreen extends StatelessWidget {
  const ConfirmLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Location')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('CONFIRM PICKUP LOCATION'),
            const SizedBox(height: 16),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all()),
              child: const Center(child: Text('[Map Preview]')),
            ),
            const Text('Green Hill Farm, Kiambu Road, Nairobi'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NavigationService.push('/farmer/sell/success');
              },
              child: const Text('YES, PICK UP HERE'),
            ),
          ],
        ),
      ),
    );
  }
}
