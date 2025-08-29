class HydrationSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double targetMl;
  final double? actualMl;
  final String containerType;
  final bool isActive;

  const HydrationSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.targetMl,
    this.actualMl,
    required this.containerType,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'target_ml': targetMl,
        'actual_ml': actualMl,
        'container_type': containerType,
        'is_active': isActive ? 1 : 0,
      };

  factory HydrationSession.fromJson(Map<String, dynamic> json) =>
      HydrationSession(
        id: json['id'],
        startTime: DateTime.parse(json['start_time']),
        endTime: json['end_time'] != null
            ? DateTime.parse(json['end_time'])
            : null,
        targetMl: json['target_ml'].toDouble(),
        actualMl: json['actual_ml']?.toDouble(),
        containerType: json['container_type'],
        isActive: json['is_active'] == 1,
      );

  HydrationSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? targetMl,
    double? actualMl,
    String? containerType,
    bool? isActive,
  }) =>
      HydrationSession(
        id: id ?? this.id,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        targetMl: targetMl ?? this.targetMl,
        actualMl: actualMl ?? this.actualMl,
        containerType: containerType ?? this.containerType,
        isActive: isActive ?? this.isActive,
      );
}