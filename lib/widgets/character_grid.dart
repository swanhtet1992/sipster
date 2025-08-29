import 'package:flutter/material.dart';
import '../models/boba_character.dart';

class CharacterGrid extends StatelessWidget {
  final List<BobaCharacter> characters;
  final String status;

  const CharacterGrid({
    super.key,
    required this.characters,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Boba Army',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                fontSize: 14,
                color: Colors.purple.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            
            if (characters.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_drink,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start drinking to recruit your first boba character!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  return CharacterCard(character: character);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  final BobaCharacter character;

  const CharacterCard({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCharacterDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: _getTypeColor().withValues(alpha: 0.1),
          border: Border.all(color: _getTypeColor().withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTypeIcon(),
              size: 32,
              color: _getTypeColor(),
            ),
            const SizedBox(height: 4),
            Text(
              character.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (character.loyaltyLevel > 0)
              Text(
                'Lv.${character.loyaltyLevel}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCharacterDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(character.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${character.type.name}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Loyalty Level: ${character.loyaltyLevel}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text('"${character.catchphrase}"'),
            if (character.unlockedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Recruited: ${_formatDate(character.unlockedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (character.type) {
      case BobaType.taro:
        return Colors.purple;
      case BobaType.matcha:
        return Colors.green;
      case BobaType.fruit:
        return Colors.orange;
      case BobaType.milkTea:
        return Colors.brown;
      case BobaType.classic:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (character.type) {
      case BobaType.taro:
        return Icons.auto_awesome;
      case BobaType.matcha:
        return Icons.energy_savings_leaf;
      case BobaType.fruit:
        return Icons.local_florist;
      case BobaType.milkTea:
        return Icons.shield;
      case BobaType.classic:
        return Icons.star;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}