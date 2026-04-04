import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class RoutineEvaluationScreen extends StatelessWidget {
  const RoutineEvaluationScreen({required this.collectionId, super.key});
  
  final String collectionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('RoutineEvaluationScreen'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RoutineEvaluationScreen - UI Coming Soon',
              style: const TextStyle(fontSize: 18),
            ),
            if (collectionId.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('ID: $collectionId'),
              ),
          ],
        ),
      ),
    );
  }
}
