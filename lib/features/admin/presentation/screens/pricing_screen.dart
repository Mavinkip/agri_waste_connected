import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing'), backgroundColor: AppColors.primaryOrange),
      body: const Center(child: Text('Pricing Management - Coming Soon')),
    );
  }
}
