import 'package:equatable/equatable.dart';
import 'preparation_step_model.dart';

class OrderPreparationState extends Equatable {
  const OrderPreparationState({
    required this.orderId,
    required this.steps,
    this.preparationStartedAt,
    this.estimatedReadyAt,
  });

  factory OrderPreparationState.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as List<dynamic>? ?? [];
    final steps = stepsJson
        .map((stepJson) => PreparationStep.fromJson(stepJson as Map<String, dynamic>))
        .toList();

    return OrderPreparationState(
      orderId: json['order_id'] as String,
      steps: steps,
      preparationStartedAt: json['preparation_started_at'] != null
          ? DateTime.parse(json['preparation_started_at'] as String)
          : null,
      estimatedReadyAt: json['estimated_ready_at'] != null
          ? DateTime.parse(json['estimated_ready_at'] as String)
          : null,
    );
  }

  final String orderId;
  final List<PreparationStep> steps;
  final DateTime? preparationStartedAt;
  final DateTime? estimatedReadyAt;

  PreparationStep? get currentStep {
    if (steps.isEmpty) return null;
    
    final inProgressStep = steps.firstWhere(
      (step) => step.isInProgress,
      orElse: () => steps.firstWhere(
        (step) => step.isPending,
        orElse: () => steps.last,
      ),
    );
    
    return inProgressStep;
  }

  double get overallProgress {
    if (steps.isEmpty) return 0.0;
    
    final completedSteps = steps.where((step) => step.isCompleted || step.isSkipped).length;
    return (completedSteps / steps.length) * 100;
  }

  int? get estimatedTimeRemaining {
    if (steps.isEmpty) return null;
    
    int totalRemaining = 0;
    
    for (final step in steps) {
      if (step.isPending) {
        totalRemaining += step.estimatedDurationSeconds;
      } else if (step.isInProgress) {
        totalRemaining += step.remainingSeconds ?? 0;
      }
    }
    
    return totalRemaining;
  }

  Duration? get estimatedTimeRemainingDuration {
    final seconds = estimatedTimeRemaining;
    if (seconds == null) return null;
    return Duration(seconds: seconds);
  }

  int get totalEstimatedDurationSeconds {
    return steps.fold(
      0,
      (sum, step) => sum + step.estimatedDurationSeconds,
    );
  }

  Duration get totalEstimatedDuration {
    return Duration(seconds: totalEstimatedDurationSeconds);
  }

  bool get isStarted => preparationStartedAt != null;
  bool get isCompleted => steps.isNotEmpty && steps.every((step) => step.isCompleted || step.isSkipped);
  bool get isInProgress => isStarted && !isCompleted;

  int get completedStepsCount {
    return steps.where((step) => step.isCompleted).length;
  }

  int get totalStepsCount => steps.length;

  List<PreparationStep> get pendingSteps {
    return steps.where((step) => step.isPending).toList();
  }

  List<PreparationStep> get completedSteps {
    return steps.where((step) => step.isCompleted).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'steps': steps.map((step) => step.toJson()).toList(),
      'preparation_started_at': preparationStartedAt?.toIso8601String(),
      'estimated_ready_at': estimatedReadyAt?.toIso8601String(),
    };
  }

  OrderPreparationState copyWith({
    String? orderId,
    List<PreparationStep>? steps,
    DateTime? preparationStartedAt,
    DateTime? estimatedReadyAt,
  }) {
    return OrderPreparationState(
      orderId: orderId ?? this.orderId,
      steps: steps ?? this.steps,
      preparationStartedAt: preparationStartedAt ?? this.preparationStartedAt,
      estimatedReadyAt: estimatedReadyAt ?? this.estimatedReadyAt,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        steps,
        preparationStartedAt,
        estimatedReadyAt,
      ];
}
