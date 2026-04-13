#!/bin/bash

# Fix WasteTypeScreen
cat > lib/features/farmer/presentation/screens/sell_waste/waste_type_screen.dart << 'WIZARD'
import 'package:flutter/material.dart';
import '../../../../../../core/services/navigation_service.dart';

class WasteTypeScreen extends StatelessWidget {
  const WasteTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Waste Type')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('WHAT ARE YOU SELLING?'),
            const SizedBox(height: 16),
            const ListTile(title: Text('Dry Stalks - KSh 5.00/kg')),
            const ListTile(title: Text('Animal Manure - KSh 3.00/kg')),
            const ListTile(title: Text('Husks & Shells - KSh 4.00/kg')),
            const ListTile(title: Text('Green Waste - KSh 2.50/kg')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NavigationService.pushNamed('/farmer/sell/quantity');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
WIZARD

# Fix QuantityScreen
cat > lib/features/farmer/presentation/screens/sell_waste/quantity_screen.dart << 'WIZARD'
import 'package:flutter/material.dart';
import '../../../../../../core/services/navigation_service.dart';

class QuantityScreen extends StatelessWidget {
  const QuantityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estimate Quantity')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('HOW MUCH DO YOU HAVE?'),
            const SizedBox(height: 16),
            const ListTile(title: Text('Small (1-5 bags ≈ 10-50 kg)')),
            const ListTile(title: Text('Medium (6-20 bags ≈ 60-200 kg)')),
            const ListTile(title: Text('Large (21-50 bags ≈ 210-500 kg)')),
            const ListTile(title: Text('Truckload (51+ bags ≈ 510+ kg)')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NavigationService.pushNamed('/farmer/sell/photo');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
WIZARD

# Fix PhotoScreen
cat > lib/features/farmer/presentation/screens/sell_waste/photo_screen.dart << 'WIZARD'
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
                NavigationService.pushNamed('/farmer/sell/location');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
WIZARD

# Fix ConfirmLocationScreen
cat > lib/features/farmer/presentation/screens/sell_waste/confirm_location_screen.dart << 'WIZARD'
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
                NavigationService.pushNamed('/farmer/sell/success');
              },
              child: const Text('YES, PICK UP HERE'),
            ),
          ],
        ),
      ),
    );
  }
}
WIZARD

# Fix SuccessScreen
cat > lib/features/farmer/presentation/screens/sell_waste/success_screen.dart << 'WIZARD'
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
                NavigationService.pushReplacementNamed('/farmer/home');
              },
              child: const Text('BACK TO HOME'),
            ),
          ],
        ),
      ),
    );
  }
}
WIZARD

echo "✅ All farmer wizard screens fixed"
