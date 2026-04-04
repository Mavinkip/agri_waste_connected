import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class FleetScreen extends StatelessWidget {
  const FleetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fleet Management'), backgroundColor: AppColors.primaryOrange),
      body: const Center(child: Text('Fleet Management - Coming Soon')),
    );
  }
}
