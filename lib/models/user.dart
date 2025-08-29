class User {
  final String id;
  final double weightKg;
  final double dailyGoalMl;
  final List<String> containerPresets;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.weightKg,
    required this.dailyGoalMl,
    required this.containerPresets,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'weight_kg': weightKg,
        'daily_goal_ml': dailyGoalMl,
        'container_presets': containerPresets.join(','),
        'created_at': createdAt.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        weightKg: json['weight_kg'].toDouble(),
        dailyGoalMl: json['daily_goal_ml'].toDouble(),
        containerPresets: json['container_presets'].toString().split(','),
        createdAt: DateTime.parse(json['created_at']),
      );
}