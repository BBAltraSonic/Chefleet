import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/preparation_step_model.dart';
import '../../../core/utils/date_time_utils.dart';

class PreparationStepsList extends StatelessWidget {
  const PreparationStepsList({
    required this.steps,
    super.key,
  });

  final List<PreparationStep> steps;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        return _buildStepItem(context, step, isLast);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: AppTheme.secondaryGreen,
          ),
          const SizedBox(height: 8),
          Text(
            'No preparation steps yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, PreparationStep step, bool isLast) {
    final isActive = step.isInProgress;
    final isCompleted = step.isCompleted;
    final isSkipped = step.isSkipped;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildStatusIndicator(step),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted || isSkipped
                        ? AppTheme.primaryGreen
                        : AppTheme.borderGreen,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.stepName,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                            color: isCompleted || isActive
                                ? AppTheme.darkText
                                : AppTheme.secondaryGreen,
                          ),
                        ),
                      ),
                      if (isActive && step.remainingSeconds != null)
                        _buildRemainingTime(context, step.remainingSeconds!),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppTheme.secondaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(step.estimatedDurationSeconds),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryGreen,
                        ),
                      ),
                      if (isCompleted && step.completedAt != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppTheme.primaryGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatCompletionTime(step.completedAt!),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(
                        value: (step.progressPercentage ?? 0) / 100,
                        backgroundColor: AppTheme.borderGreen,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryGreen,
                        ),
                        minHeight: 4,
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

  Widget _buildStatusIndicator(PreparationStep step) {
    final isActive = step.isInProgress;
    final isCompleted = step.isCompleted;
    final isSkipped = step.isSkipped;

    if (isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 16,
        ),
      );
    }

    if (isSkipped) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.secondaryGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.skip_next,
          color: Colors.white,
          size: 16,
        ),
      );
    }

    if (isActive) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryGreen,
            width: 3,
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.borderGreen,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${step.stepNumber}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildRemainingTime(BuildContext context, int seconds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatDuration(seconds),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.primaryGreen,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }

  String _formatCompletionTime(DateTime completedAt) {
    return DateTimeUtils.formatTimeAgo(completedAt);
  }
}
