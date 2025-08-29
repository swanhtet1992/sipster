import 'package:flutter/material.dart';
import '../models/boba_character.dart';
import '../theme/design_constants.dart';
import '../utils/platform_utils.dart';

class CharacterGrid extends StatelessWidget {
  final List<BobaCharacter> characters;
  final String status;
  final Map<String, dynamic>? armyStatus;
  final VoidCallback? onCharacterTap;

  const CharacterGrid({
    super.key,
    required this.characters,
    required this.status,
    this.armyStatus,
    this.onCharacterTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get platform-specific dimensions and layout
    final isDesktop = PlatformUtils.isDesktop(context);
    final isTablet = PlatformUtils.isTablet(context);
    
    final characterCardSize = PlatformUtils.getCharacterCardSize(context);
    final crossAxisCount = PlatformUtils.getGridCrossAxisCount(context);
    final platformPadding = PlatformUtils.getPlatformPadding(context);
    final platformSpacing = PlatformUtils.getPlatformSpacing(context);
    
    // Calculate dynamic height based on content and platform
    final baseHeight = isDesktop ? 300.0 : (isTablet ? 280.0 : 240.0);
    final calculatedHeight = characters.isNotEmpty 
        ? ((characters.length / crossAxisCount).ceil() * (characterCardSize + platformSpacing)) + 120
        : baseHeight;
    final displayHeight = calculatedHeight.clamp(baseHeight, isDesktop ? 400.0 : 320.0);

    return Container(
      height: displayHeight,
      decoration: _getContainerDecoration(),
      child: Padding(
        padding: platformPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: platformSpacing * 0.5),
            _buildStatusBadge(context),
            SizedBox(height: platformSpacing),
            Expanded(child: _buildCharacterContent(context)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _getContainerDecoration() {
    // Enhanced decoration based on army status
    final statusColor = armyStatus != null 
        ? _getStatusColor(armyStatus!['color'] ?? 'default')
        : DesignConstants.primary;
    
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          statusColor.withValues(alpha: 0.1),
          statusColor.withValues(alpha: 0.05),
          DesignConstants.secondary.withValues(alpha: 0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(DesignConstants.radiusL),
      border: Border.all(
        color: statusColor.withValues(alpha: 0.3),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: statusColor.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDesktop = PlatformUtils.isDesktop(context);
    final headerIcon = armyStatus != null ? _getStatusIcon(armyStatus!['mood'] ?? 'neutral') : '⚔️';
    
    return Row(
      children: [
        AnimatedSwitcher(
          duration: DesignConstants.animationNormal,
          child: Text(
            headerIcon,
            key: ValueKey(headerIcon),
            style: TextStyle(fontSize: isDesktop ? 24 : 20),
          ),
        ),
        SizedBox(width: PlatformUtils.getPlatformSpacing(context) * 0.5),
        Expanded(
          child: Text(
            'Your Boba Army',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontTitle),
              fontWeight: FontWeight.bold,
              color: DesignConstants.textPrimary,
            ),
          ),
        ),
        if (characters.isNotEmpty && PlatformUtils.isDesktop(context))
          _buildArmyCountBadge(context),
      ],
    );
  }

  Widget _buildArmyCountBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignConstants.spacingS,
        vertical: DesignConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: DesignConstants.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignConstants.radiusXL),
        border: Border.all(
          color: DesignConstants.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '${characters.length} warriors',
        style: TextStyle(
          fontFamily: 'SF Pro Text',
          fontSize: DesignConstants.fontCaption,
          color: DesignConstants.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final statusColor = armyStatus != null 
        ? _getStatusColor(armyStatus!['color'] ?? 'default')
        : DesignConstants.getArmyStatusColor(status);

    final displayStatus = armyStatus?['message'] ?? status;
    final isDesktop = PlatformUtils.isDesktop(context);

    return AnimatedContainer(
      duration: DesignConstants.animationNormal,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? DesignConstants.spacingL : DesignConstants.spacingM,
        vertical: isDesktop ? DesignConstants.spacingS : DesignConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignConstants.radiusXL),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (armyStatus?['bubbleSynergy'] == true) ...[
            const Text('✨', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              displayStatus,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontBody),
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
              maxLines: isDesktop ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterContent(BuildContext context) {
    if (characters.isEmpty) {
      return _buildEmptyState(context);
    }

    final crossAxisCount = PlatformUtils.getGridCrossAxisCount(context);
    final characterCardSize = PlatformUtils.getCharacterCardSize(context);
    final platformSpacing = PlatformUtils.getPlatformSpacing(context);
    
    // Show only the optimal number of characters for the platform
    final displayCount = PlatformUtils.getCharacterDisplayCount(context);
    final displayCharacters = characters.take(displayCount).toList();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: PlatformUtils.isDesktop(context) ? 0.9 : 0.8,
        crossAxisSpacing: platformSpacing * 0.5,
        mainAxisSpacing: platformSpacing * 0.5,
      ),
      itemCount: displayCharacters.length,
      itemBuilder: (context, index) {
        final character = displayCharacters[index];
        return ResponsiveCharacterCard(
          character: character,
          size: characterCardSize,
          armyMood: armyStatus?['mood'] ?? 'neutral',
          onTap: onCharacterTap,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDesktop = PlatformUtils.isDesktop(context);
    final emptySize = isDesktop ? 100.0 : 80.0;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: emptySize,
            height: emptySize,
            decoration: BoxDecoration(
              color: DesignConstants.steamGray.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignConstants.radiusL),
              border: Border.all(
                color: DesignConstants.steamGray.withValues(alpha: 0.3),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.add,
              size: emptySize * 0.5,
              color: DesignConstants.steamGray,
            ),
          ),
          SizedBox(height: PlatformUtils.getPlatformSpacing(context)),
          Text(
            'Start drinking to recruit\nyour first boba warrior!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontBody),
              color: DesignConstants.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'rainbow': return DesignConstants.celebration;
      case 'green': return DesignConstants.success;
      case 'blue': return Colors.blue;
      case 'orange': return DesignConstants.warning;
      case 'red': return Colors.red;
      case 'yellow': return DesignConstants.brownSugar;
      case 'grey': return DesignConstants.steamGray;
      default: return DesignConstants.primary;
    }
  }

  String _getStatusIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'euphoric': return '✨';
      case 'happy': return '🎉';
      case 'sluggish': return '💧';
      case 'sad': return '😔';
      case 'worried': return '😟';
      case 'content': return '😊';
      default: return '⚔️';
    }
  }
}

class ResponsiveCharacterCard extends StatefulWidget {
  final BobaCharacter character;
  final double size;
  final String armyMood;
  final VoidCallback? onTap;

  const ResponsiveCharacterCard({
    super.key,
    required this.character,
    required this.size,
    required this.armyMood,
    this.onTap,
  });

  @override
  State<ResponsiveCharacterCard> createState() => _ResponsiveCharacterCardState();
}

class _ResponsiveCharacterCardState extends State<ResponsiveCharacterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showCatchphrase = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignConstants.animationNormal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = DesignConstants.getBobaTypeColor(widget.character.type.name);
    final isDesktop = PlatformUtils.isDesktop(context);
    final supportsHover = PlatformUtils.supportsHover(context);
    
    return MouseRegion(
      onEnter: supportsHover ? (_) => _animationController.forward() : null,
      onExit: supportsHover ? (_) => _animationController.reverse() : null,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _handleTap(context),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: DesignConstants.animationFast,
                curve: Curves.easeInOut,
                decoration: _getCardDecoration(typeColor),
                child: Stack(
                  children: [
                    _buildCardContent(context, typeColor, isDesktop),
                    if (_showCatchphrase && isDesktop)
                      _buildCatchphraseOverlay(context, typeColor),
                    _buildMoodEffect(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _getCardDecoration(Color typeColor) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          typeColor.withValues(alpha: _getMoodOpacity()),
          typeColor.withValues(alpha: _getMoodOpacity() * 0.3),
        ],
      ),
      border: Border.all(
        color: typeColor.withValues(alpha: 0.6),
        width: 2,
      ),
      borderRadius: BorderRadius.circular(DesignConstants.radiusM),
      boxShadow: [
        BoxShadow(
          color: typeColor.withValues(alpha: 0.3),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  double _getMoodOpacity() {
    switch (widget.armyMood.toLowerCase()) {
      case 'euphoric': return 0.3;
      case 'happy': return 0.25;
      case 'sluggish': return 0.1;
      case 'sad': return 0.15;
      case 'worried': return 0.2;
      default: return 0.2;
    }
  }

  Widget _buildCardContent(BuildContext context, Color typeColor, bool isDesktop) {
    final cardSize = widget.size;
    final iconSize = cardSize * 0.4;
    
    return Padding(
      padding: EdgeInsets.all(cardSize * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Character Icon with mood animation
          AnimatedContainer(
            duration: DesignConstants.animationNormal,
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(DesignConstants.radiusS),
              border: Border.all(
                color: typeColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Icon(
              _getTypeIcon(),
              size: iconSize * 0.6,
              color: typeColor,
            ),
          ),
          SizedBox(height: cardSize * 0.08),
          
          // Character Name
          Text(
            widget.character.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: isDesktop ? DesignConstants.fontCaption + 1 : DesignConstants.fontCaption,
              fontWeight: FontWeight.w600,
              color: DesignConstants.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Loyalty Level Badge
          if (widget.character.loyaltyLevel > 0) ...[
            SizedBox(height: cardSize * 0.05),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: cardSize * 0.08,
                vertical: cardSize * 0.02,
              ),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(cardSize * 0.05),
              ),
              child: Text(
                'Lv.${widget.character.loyaltyLevel}',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: isDesktop ? DesignConstants.fontSmall + 1 : DesignConstants.fontSmall,
                  fontWeight: FontWeight.bold,
                  color: DesignConstants.pearlWhite,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCatchphraseOverlay(BuildContext context, Color typeColor) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: typeColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(DesignConstants.radiusM),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '"${widget.character.catchphrase}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: DesignConstants.fontCaption,
                fontWeight: FontWeight.w600,
                color: DesignConstants.pearlWhite,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodEffect(BuildContext context) {
    if (widget.armyMood == 'euphoric') {
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignConstants.radiusM),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.yellow.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.blue.withValues(alpha: 0.2),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _handleTap(BuildContext context) {
    if (PlatformUtils.isDesktop(context)) {
      setState(() {
        _showCatchphrase = !_showCatchphrase;
      });
      
      // Hide catchphrase after 3 seconds
      if (_showCatchphrase) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showCatchphrase = false;
            });
          }
        });
      }
    } else {
      _showCharacterDetails(context);
    }
    
    widget.onTap?.call();
  }

  void _showCharacterDetails(BuildContext context) {
    final maxDialogWidth = PlatformUtils.getMaxDialogWidth(context);
    
    showDialog<void>(
      context: context,
      builder: (context) => Container(
        constraints: BoxConstraints(maxWidth: maxDialogWidth),
        child: AlertDialog(
          title: Text(widget.character.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Type: ${widget.character.type.name}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Loyalty Level: ${widget.character.loyaltyLevel}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DesignConstants.milkTeaBeige.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${widget.character.catchphrase}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (widget.character.unlockedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Recruited: ${_formatDate(widget.character.unlockedAt!)}',
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
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (widget.character.type) {
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

// Legacy CharacterCard for backwards compatibility
class CharacterCard extends StatelessWidget {
  final BobaCharacter character;

  const CharacterCard({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final typeColor = DesignConstants.getBobaTypeColor(character.type.name);
    
    return GestureDetector(
      onTap: () => _showCharacterDetails(context),
      child: AnimatedContainer(
        duration: DesignConstants.animationFast,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              typeColor.withValues(alpha: 0.15),
              typeColor.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(
            color: typeColor.withValues(alpha: 0.4),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(DesignConstants.radiusM),
          boxShadow: [
            BoxShadow(
              color: typeColor.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignConstants.spacingS),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Character Sprite Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignConstants.radiusS),
                ),
                child: Icon(
                  _getTypeIcon(),
                  size: 24,
                  color: typeColor,
                ),
              ),
              const SizedBox(height: DesignConstants.spacingXS),
              // Character Name
              Text(
                character.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: DesignConstants.fontCaption,
                  fontWeight: FontWeight.w600,
                  color: DesignConstants.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Rank Badge
              if (character.loyaltyLevel > 0) ...[
                const SizedBox(height: DesignConstants.spacingXS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignConstants.spacingXS,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(DesignConstants.spacingXS),
                  ),
                  child: Text(
                    'Lv.${character.loyaltyLevel}',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: DesignConstants.fontSmall,
                      fontWeight: FontWeight.bold,
                      color: DesignConstants.pearlWhite,
                    ),
                  ),
                ),
              ],
            ],
          ),
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