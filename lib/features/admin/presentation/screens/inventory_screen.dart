import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory'), backgroundColor: AppColors.primaryOrange),
      body: const Center(child: Text('Inventory Management - Coming Soon')),
    );
  }
}
