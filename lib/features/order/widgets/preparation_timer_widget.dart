import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../models/preparation_step_model.dart';

class PreparationTimerWidget extends StatefulWidget {
  const PreparationTimerWidget({
    required this.currentStep,
    this.totalSteps = 0,
    this.completedSteps = 0,
    super.key,
  });

  final PreparationStep? currentStep;
  final int totalSteps;
  final int completedSteps;

  @override
  State<PreparationTimerWidget> createState() => _PreparationTimerWidgetState();
}

class _PreparationTimerWidgetState extends State<PreparationTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.currentStep;
    
    if (step == null) {
      return _buildNoActiveStepView();
    }

    // If step is pending (not started), use estimated duration
    final remainingSeconds = step.startedAt != null 
        ? (step.remainingSeconds ?? 0)
        : step.estimatedDurationSeconds;
        
    final progress = step.progressPercentage ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderGreen),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.borderGreen,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(remainingSeconds),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    Text(
                      'remaining',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.secondaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.stepName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildNoActiveStepView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderGreen),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 12),
          Text(
            'All steps completed!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle,
          size: 16,
          color: AppTheme.secondaryGreen,
        ),
        const SizedBox(width: 4),
        Text(
          'Step ${widget.completedSteps + 1} of ${widget.totalSteps}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.secondaryGreen,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) {
      return Colors.red;
    } else if (progress >= 50) {
      return Colors.orange;
    }
    return AppTheme.primaryGreen;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
