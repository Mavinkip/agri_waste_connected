import 'package:flutter/material.dart';
import '../../../../../../core/services/navigation_service.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✓'),
            const SizedBox(height: 16),
            const Text('SUCCESS! Your waste is listed for pickup!'),
            const Text('Ticket #: AG-38492'),
            const SizedBox(height: 16),
            const Text("You'll receive an SMS when a driver is assigned."),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NavigationService.pushReplacement('/farmer/home');
              },
              child: const Text('BACK TO HOME'),
            ),
          ],
        ),
      ),
    );
  }
}
