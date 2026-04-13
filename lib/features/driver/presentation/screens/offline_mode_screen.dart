import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class OfflineModeScreen extends StatelessWidget {
  const OfflineModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠ OFFLINE MODE'),
            const SizedBox(height: 16),
            const Text('No internet detected. You can still complete all pickups.'),
            const Text('Your data is saved on this device.'),
            const SizedBox(height: 8),
            const Text('Waiting to sync: 3 transactions'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  NavigationService.back();
                },
                child: const Text('CONTINUE OFFLINE'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('TRY RECONNECT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
