import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class WeighInScreen extends StatefulWidget {
  final String collectionId;
  const WeighInScreen({super.key, required this.collectionId});

  @override
  State<WeighInScreen> createState() => _WeighInScreenState();
}

class _WeighInScreenState extends State<WeighInScreen> {
  String weight = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weigh-In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('WEIGH-IN'),
            Text('Collection ID: ${widget.collectionId}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all()),
              child: Column(
                children: [
                  Text(
                    weight.isEmpty ? '0' : weight,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const Text('kg'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: [
                for (int i = 1; i <= 9; i++)
                  ElevatedButton(
                    onPressed: () => setState(() => weight += i.toString()),
                    child: Text('$i'),
                  ),
                ElevatedButton(
                  onPressed: () => setState(() => weight += '0'),
                  child: const Text('0'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    if (weight.isNotEmpty) weight = weight.substring(0, weight.length - 1);
                  }),
                  child: const Text('⌫'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Payout: KSh ${(int.tryParse(weight) ?? 0) * 5}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: weight.isEmpty ? null : () {
                  NavigationService.pushReplacementNamed('/driver/quality');
                },
                child: const Text('CONFIRM WEIGHT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
