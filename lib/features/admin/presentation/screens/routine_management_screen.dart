import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class RoutineManagementScreen extends StatelessWidget {
  const RoutineManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Routine Management'), backgroundColor: AppColors.primaryOrange),
      body: const Center(child: Text('Routine Management - Coming Soon')),
    );
  }
}
