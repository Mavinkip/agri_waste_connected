import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class FarmLocationScreen extends StatelessWidget {
  const FarmLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('FarmLocationScreen'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: const Center(
        child: Text('FarmLocationScreen - UI Coming Soon'),
      ),
    );
  }
}
