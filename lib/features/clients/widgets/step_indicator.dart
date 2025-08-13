import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepTitles;
  final List<String>? steps;
  final VoidCallback? onStepTap;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitles,
    this.steps,
    this.onStepTap,
  });

  List<String> get _steps {
    return steps ?? stepTitles ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: currentStep / totalSteps,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(context.brandOrange),
          minHeight: 4,
        ),
        const SizedBox(height: 16),
        
        // Step indicators
        Row(
          children: List.generate(totalSteps, (index) {
            final stepNumber = index + 1;
            final isCompleted = stepNumber < currentStep;
            final isCurrent = stepNumber == currentStep;
            final isActive = isCompleted || isCurrent;
            
            return Expanded(
              child: GestureDetector(
                onTap: onStepTap != null && stepNumber <= currentStep 
                    ? onStepTap 
                    : null,
                child: Column(
                  children: [
                    // Step circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted 
                            ? context.brandOrange
                            : isCurrent 
                                ? context.brandOrange.withOpacity(0.2)
                                : Colors.grey[300],
                        border: isCurrent 
                            ? Border.all(
                                color: context.brandOrange,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                stepNumber.toString(),
                                style: TextStyle(
                                  color: isCurrent 
                                      ? context.brandOrange
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Step title
                    if (index < _steps.length)
                      Text(
                        _steps[index],
                        style: TextStyle(
                          color: isActive 
                              ? context.brandOrange
                              : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: isCurrent 
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
