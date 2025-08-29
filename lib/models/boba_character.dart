enum BobaType { milkTea, taro, matcha, fruit, classic }

class BobaCharacter {
  final String id;
  final String name;
  final BobaType type;
  final bool isUnlocked;
  final int loyaltyLevel;
  final DateTime? unlockedAt;
  final String catchphrase;

  const BobaCharacter({
    required this.id,
    required this.name,
    required this.type,
    required this.isUnlocked,
    required this.loyaltyLevel,
    this.unlockedAt,
    required this.catchphrase,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'is_unlocked': isUnlocked ? 1 : 0,
        'loyalty_level': loyaltyLevel,
        'unlocked_at': unlockedAt?.toIso8601String(),
        'catchphrase': catchphrase,
      };

  factory BobaCharacter.fromJson(Map<String, dynamic> json) => BobaCharacter(
        id: json['id'],
        name: json['name'],
        type: BobaType.values.firstWhere((e) => e.name == json['type']),
        isUnlocked: json['is_unlocked'] == 1,
        loyaltyLevel: json['loyalty_level'],
        unlockedAt: json['unlocked_at'] != null
            ? DateTime.parse(json['unlocked_at'])
            : null,
        catchphrase: json['catchphrase'],
      );

  BobaCharacter copyWith({
    String? id,
    String? name,
    BobaType? type,
    bool? isUnlocked,
    int? loyaltyLevel,
    DateTime? unlockedAt,
    String? catchphrase,
  }) =>
      BobaCharacter(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        loyaltyLevel: loyaltyLevel ?? this.loyaltyLevel,
        unlockedAt: unlockedAt ?? this.unlockedAt,
        catchphrase: catchphrase ?? this.catchphrase,
      );
}