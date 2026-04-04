import 'package:flutter/material.dart';
import '../../../../../../core/services/navigation_service.dart';

class PhotoScreen extends StatelessWidget {
  const PhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take Photo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('SHOW YOUR WASTE - Take a clear photo'),
            const SizedBox(height: 16),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all()),
              child: const Center(child: Text('Tap to Take Photo')),
            ),
            const SizedBox(height: 16),
            const Text('Tips: Show full pile, good lighting, no plastic'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NavigationService.push('/farmer/sell/location');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
