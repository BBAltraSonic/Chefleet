import 'package:equatable/equatable.dart';
import '../../../core/utils/date_time_utils.dart';

class PreparationStep extends Equatable {
  const PreparationStep({
    required this.id,
    required this.orderItemId,
    required this.stepNumber,
    required this.stepName,
    required this.estimatedDurationSeconds,
    this.startedAt,
    this.completedAt,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PreparationStep.fromJson(Map<String, dynamic> json) {
    return PreparationStep(
      id: json['id'] as String,
      orderItemId: json['order_item_id'] as String,
      stepNumber: json['step_number'] as int,
      stepName: json['step_name'] as String,
      estimatedDurationSeconds: json['estimated_duration_seconds'] as int,
      startedAt: DateTimeUtils.parse(json['started_at'] as String?),
      completedAt: DateTimeUtils.parse(json['completed_at'] as String?),
      status: json['status'] as String,
      createdAt: DateTimeUtils.parse(json['created_at'] as String?),
      updatedAt: DateTimeUtils.parse(json['updated_at'] as String?),
    );
  }

  final String id;
  final String orderItemId;
  final int stepNumber;
  final String stepName;
  final int estimatedDurationSeconds;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static const validStatuses = ['pending', 'in_progress', 'completed', 'skipped'];

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isSkipped => status == 'skipped';
  bool get isActive => status == 'in_progress';

  int? get remainingSeconds {
    if (startedAt == null || !isInProgress) return null;
    
    final elapsed = DateTime.now().difference(startedAt!).inSeconds;
    final remaining = estimatedDurationSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  double? get progressPercentage {
    if (startedAt == null || !isInProgress) {
      if (isCompleted) return 100.0;
      return 0.0;
    }
    
    final elapsed = DateTime.now().difference(startedAt!).inSeconds;
    final progress = (elapsed / estimatedDurationSeconds) * 100;
    return progress.clamp(0.0, 100.0);
  }

  Duration get estimatedDuration => Duration(seconds: estimatedDurationSeconds);

  Duration? get elapsedDuration {
    if (startedAt == null) return null;
    
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_item_id': orderItemId,
      'step_number': stepNumber,
      'step_name': stepName,
      'estimated_duration_seconds': estimatedDurationSeconds,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PreparationStep copyWith({
    String? id,
    String? orderItemId,
    int? stepNumber,
    String? stepName,
    int? estimatedDurationSeconds,
    DateTime? startedAt,
    DateTime? completedAt,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PreparationStep(
      id: id ?? this.id,
      orderItemId: orderItemId ?? this.orderItemId,
      stepNumber: stepNumber ?? this.stepNumber,
      stepName: stepName ?? this.stepName,
      estimatedDurationSeconds: estimatedDurationSeconds ?? this.estimatedDurationSeconds,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderItemId,
        stepNumber,
        stepName,
        estimatedDurationSeconds,
        startedAt,
        completedAt,
        status,
        createdAt,
        updatedAt,
      ];
}
