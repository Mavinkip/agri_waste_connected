import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final String collectionId;
  const PaymentConfirmationScreen({super.key, required this.collectionId});

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
            const Text('PAYMENT SENT!'),
            const SizedBox(height: 16),
            Text('Collection ID: $collectionId'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all()),
              child: const Column(
                children: [
                  Text('Farmer: Green Hill Farm'),
                  Text('Amount: KSh 2,250'),
                  Text('M-Pesa Ref: MPESA-123456'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  NavigationService.pushReplacement('/driver/route');
                },
                child: const Text('NEXT PICKUP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
