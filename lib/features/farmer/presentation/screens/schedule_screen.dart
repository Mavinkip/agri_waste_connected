import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule'), backgroundColor: AppColors.primaryGreen),
      body: const Center(child: Text('Schedule Screen - Coming Soon')),
    );
  }
}
