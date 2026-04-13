import 'package:flutter/material.dart';

class PriceControllerScreen extends StatefulWidget {
  const PriceControllerScreen({super.key});

  @override
  State<PriceControllerScreen> createState() => _PriceControllerScreenState();
}

class _PriceControllerScreenState extends State<PriceControllerScreen> {
  final Map<String, TextEditingController> _controllers = {
    'Dry Stalks': TextEditingController(text: '5.00'),
    'Manure': TextEditingController(text: '3.00'),
    'Husks': TextEditingController(text: '4.00'),
    'Green Waste': TextEditingController(text: '2.50'),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Price Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CURRENT BUYING RATES'),
            const SizedBox(height: 8),
            for (var entry in _controllers.entries)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(border: Border.all()),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: entry.value,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'KSh/kg'),
                      ),
                    ),
                    IconButton(
                      icon: const Text('Save'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Text('Bulk Update:'),
            Row(
              children: [
                const Expanded(child: TextField(decoration: InputDecoration(labelText: 'Price per kg'))),
                ElevatedButton(onPressed: () {}, child: const Text('APPLY')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(value: true, onChanged: null),
                const Text('Notify all farmers when prices change'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('SAVE ALL CHANGES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
