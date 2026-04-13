import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/services/navigation_service.dart';

class WizardTemplate extends StatelessWidget {
  final String title;
  final String description;
  final Widget content;
  final int currentStep;
  final int totalSteps;
  
  const WizardTemplate({
    super.key,
    required this.title,
    required this.description,
    required this.content,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (currentStep > 0) {
              NavigationService.pop();
            } else {
              NavigationService.pushReplacement('/farmer/home');
            }
          },
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentStep + 1) / totalSteps,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(child: content),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (currentStep + 1 < totalSteps) {
                        // Navigate to next step
                      } else {
                        NavigationService.pushReplacement('/farmer/sell/success');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      currentStep + 1 == totalSteps ? AppStrings.submit : AppStrings.next,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
