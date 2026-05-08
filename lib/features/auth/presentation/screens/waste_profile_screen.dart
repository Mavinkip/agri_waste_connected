import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
<<<<<<< HEAD
=======
import '../../../../core/constants/app_strings.dart';
>>>>>>> upstream/master

class WasteProfileScreen extends StatelessWidget {
  const WasteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('WasteProfileScreen'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: const Center(
        child: Text('WasteProfileScreen - UI Coming Soon'),
      ),
    );
  }
}
