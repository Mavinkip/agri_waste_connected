// lib/features/farmer/presentation/screens/sell_waste/wizard_template.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/sell_wizard_cubit.dart';
import '../../../../../core/constants/app_colors.dart';

class WizardTemplate extends StatelessWidget {
  final String title;
  final String description;
  final Widget content;
  final VoidCallback? onNext;
  final bool canProceed;
  final bool isLastStep;
  final bool isSubmitting;

  const WizardTemplate({
    super.key,
    required this.title,
    required this.description,
    required this.content,
    this.onNext,
    this.canProceed = true,
    this.isLastStep = false,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<SellWizardCubit>().previousStep();
          },
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          BlocBuilder<SellWizardCubit, SellWizardState>(
            builder: (context, state) {
              return LinearProgressIndicator(
                value: (state.currentStep + 1) / 4,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryGreen,
                ),
              );
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Content
                  content,
                  const SizedBox(height: 24),

                  // Next/Submit Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (canProceed && !isSubmitting) ? onNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isLastStep ? 'Submit Listing' : 'Continue',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
