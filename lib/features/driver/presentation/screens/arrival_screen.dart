import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class ArrivalScreen extends StatefulWidget {
  final String collectionId;
  const ArrivalScreen({super.key, required this.collectionId});

  @override
  State<ArrivalScreen> createState() => _ArrivalScreenState();
}

class _ArrivalScreenState extends State<ArrivalScreen> {
  bool photoTaken = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arrival at Farm')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('YOU HAVE ARRIVED'),
            const SizedBox(height: 8),
            Text('Collection ID: ${widget.collectionId}'),
            const Text('Green Hill Farm'),
            const Text('Kiambu Road, Nairobi'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() => photoTaken = true),
                child: const Text('TAKE PHOTO of waste pile'),
              ),
            ),
            if (photoTaken) const Text('✓ Photo taken'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: photoTaken ? () {
                  NavigationService.pushReplacementNamed('/driver/weigh');
                } : null,
                child: const Text('RECORD WEIGHT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
