import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class QualityCheckScreen extends StatefulWidget {
  final String collectionId;
  const QualityCheckScreen({super.key, required this.collectionId});

  @override
  State<QualityCheckScreen> createState() => _QualityCheckScreenState();
}

class _QualityCheckScreenState extends State<QualityCheckScreen> {
  String? qualityRating;
  bool signatureDone = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quality Check & Signature')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Collection ID: ${widget.collectionId}'),
            const SizedBox(height: 8),
            const Text('QUALITY CHECK'),
            ListTile(
              title: const Text('Yes, good quality'),
              leading: Radio<String>(
                value: 'Good',
                groupValue: qualityRating,
                onChanged: (value) => setState(() => qualityRating = value),
              ),
            ),
            ListTile(
              title: const Text('No, downgrade price'),
              leading: Radio<String>(
                value: 'Downgrade',
                groupValue: qualityRating,
                onChanged: (value) => setState(() => qualityRating = value),
              ),
            ),
            const SizedBox(height: 16),
            const Text('FARMER SIGNATURE'),
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all()),
              child: Center(
                child: signatureDone
                    ? const Text('✓ Signature captured')
                    : ElevatedButton(
                        onPressed: () => setState(() => signatureDone = true),
                        child: const Text('Tap to Sign'),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (qualityRating != null && signatureDone) ? () {
                  NavigationService.pushReplacementNamed('/driver/payment');
                } : null,
                child: const Text('COMPLETE & PAY'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
