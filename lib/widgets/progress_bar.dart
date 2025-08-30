import 'package:flutter/material.dart';
import '../theme/design_constants.dart';
import '../utils/platform_utils.dart';
import '../models/safety_warning.dart';

class ProgressBar extends StatefulWidget {
  final double progress;
  final double current;
  final double goal;
  final double kidneyLoad;
  final double hourlyRate;
  final SafetyWarning? currentWarning;
  final Map<String, dynamic>? enhancedSafetyData;
  final bool showDetailedStats;

  const ProgressBar({
    super.key,
    required this.progress,
    required this.current,
    required this.goal,
    required this.kidneyLoad,
    this.hourlyRate = 0.0,
    this.currentWarning,
    this.enhancedSafetyData,
    this.showDetailedStats = false,
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignConstants.animationSlow,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _updateColorAnimation();
    
    // Start pulsing if there's a warning
    if (widget.currentWarning != null && widget.currentWarning!.isHighPriority) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    _updateColorAnimation();
    
    // Handle animation state based on warning level
    if (widget.currentWarning != null && widget.currentWarning!.isHighPriority) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  void _updateColorAnimation() {
    final warningColor = widget.currentWarning?.warningColor ?? DesignConstants.success;
    _colorAnimation = ColorTween(
      begin: DesignConstants.primary,
      end: warningColor,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformUtils.isDesktop(context);
    final platformPadding = PlatformUtils.getPlatformPadding(context);
    final platformSpacing = PlatformUtils.getPlatformSpacing(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.currentWarning?.isHighPriority == true ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: _getContainerDecoration(),
            child: Padding(
              padding: platformPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isDesktop, platformSpacing),
                  SizedBox(height: platformSpacing),
                  _buildMainProgressBar(context, isDesktop),
                  SizedBox(height: platformSpacing * 0.5),
                  _buildProgressLabels(context, isDesktop),
                  if (_shouldShowKidneyLoad()) ...[
                    SizedBox(height: platformSpacing),
                    _buildKidneyLoadGauge(context, isDesktop),
                  ],
                  if (widget.showDetailedStats && widget.enhancedSafetyData != null) ...[
                    SizedBox(height: platformSpacing),
                    _buildDetailedStats(context, isDesktop),
                  ],
                  if (widget.currentWarning != null) ...[
                    SizedBox(height: platformSpacing),
                    _buildSafetyWarning(context, isDesktop),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _getContainerDecoration() {
    final warningColor = widget.currentWarning?.warningColor;
    
    // Get status-based color like the Boba Army widget
    final statusColor = widget.progress >= 100 
        ? DesignConstants.success 
        : (widget.currentWarning?.isHighPriority == true ? warningColor ?? DesignConstants.warning : DesignConstants.primary);
    
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

  Widget _buildHeader(BuildContext context, bool isDesktop, double spacing) {
    final warningColor = _colorAnimation.value ?? DesignConstants.primary;
    
    return Row(
      children: [
        AnimatedContainer(
          duration: DesignConstants.animationNormal,
          padding: EdgeInsets.all(spacing * 0.6),
          decoration: BoxDecoration(
            color: warningColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignConstants.radiusS),
          ),
          child: Icon(
            _getHeaderIcon(),
            color: warningColor,
            size: isDesktop ? 24 : 20,
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Victory Progress',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontTitle),
                  fontWeight: FontWeight.bold,
                  color: DesignConstants.textPrimary,
                ),
              ),
              Text(
                _getProgressSubtitle(),
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontBody),
                  color: DesignConstants.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _buildProgressBadge(context, isDesktop, warningColor),
      ],
    );
  }

  IconData _getHeaderIcon() {
    if (widget.currentWarning != null) {
      switch (widget.currentWarning!.level) {
        case SafetyLevel.danger:
          return Icons.warning;
        case SafetyLevel.warning:
          return Icons.info;
        case SafetyLevel.info:
          return Icons.check_circle;
      }
    }
    return widget.progress >= 100 ? Icons.celebration : Icons.timeline;
  }

  String _getProgressSubtitle() {
    if (widget.currentWarning != null) {
      return widget.currentWarning!.title;
    }
    
    if (widget.progress >= 100) {
      return 'Victory achieved! 🎉';
    }
    
    final remaining = widget.goal - widget.current;
    return '${remaining.round()}ml to victory!';
  }

  Widget _buildProgressBadge(BuildContext context, bool isDesktop, Color color) {
    return AnimatedContainer(
      duration: DesignConstants.animationNormal,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? DesignConstants.spacingL : DesignConstants.spacingM,
        vertical: DesignConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: widget.progress >= 100 
          ? DesignConstants.success.withValues(alpha: 0.1)
          : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignConstants.radiusXL),
        border: Border.all(
          color: widget.progress >= 100 
            ? DesignConstants.success.withValues(alpha: 0.4)
            : color.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        '${widget.progress.round()}%',
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontBody),
          fontWeight: FontWeight.bold,
          color: widget.progress >= 100 ? DesignConstants.success : color,
        ),
      ),
    );
  }

  Widget _buildMainProgressBar(BuildContext context, bool isDesktop) {
    final barHeight = isDesktop ? 16.0 : 12.0;
    final progressWidth = MediaQuery.of(context).size.width - 64;
    
    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: DesignConstants.cupRim,
        borderRadius: BorderRadius.circular(barHeight / 2),
        boxShadow: [
          BoxShadow(
            color: DesignConstants.tapiocaBlack.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated progress fill
          AnimatedContainer(
            duration: DesignConstants.animationNormal,
            width: progressWidth * (widget.progress / 100).clamp(0.0, 1.0),
            decoration: BoxDecoration(
              gradient: _getProgressGradient(),
              borderRadius: BorderRadius.circular(barHeight / 2),
            ),
          ),
          // Enhanced milestone markers
          ..._buildMilestoneMarkers(context, progressWidth, barHeight),
        ],
      ),
    );
  }

  LinearGradient _getProgressGradient() {
    if (widget.currentWarning != null) {
      final warningColor = widget.currentWarning!.warningColor ?? DesignConstants.warning;
      return LinearGradient(
        colors: [warningColor.withValues(alpha: 0.8), warningColor],
      );
    }
    
    return widget.progress >= 100 
        ? LinearGradient(colors: [DesignConstants.success, DesignConstants.matchaGreen])
        : DesignConstants.progressGradient;
  }

  List<Widget> _buildMilestoneMarkers(BuildContext context, double width, double height) {
    final milestones = [25.0, 50.0, 75.0];
    return milestones.map((milestone) {
      final isReached = widget.progress >= milestone;
      return Positioned(
        left: (width * (milestone / 100)) - 4,
        top: (height - 8) / 2,
        child: AnimatedContainer(
          duration: DesignConstants.animationNormal,
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isReached ? DesignConstants.pearlWhite : DesignConstants.steamGray,
            shape: BoxShape.circle,
            border: Border.all(
              color: isReached ? DesignConstants.primary : DesignConstants.steamGray,
              width: 1.5,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildProgressLabels(BuildContext context, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${widget.current.round()}ml',
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontCaption),
            fontWeight: FontWeight.w600,
            color: DesignConstants.textPrimary,
          ),
        ),
        if (widget.hourlyRate > 0 && isDesktop)
          Text(
            '${widget.hourlyRate.round()}ml/hr',
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontSmall),
              color: DesignConstants.textSecondary,
            ),
          ),
        Text(
          'Goal: ${widget.goal.round()}ml',
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontCaption),
            color: DesignConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  bool _shouldShowKidneyLoad() {
    return widget.kidneyLoad > 30 || widget.currentWarning != null;
  }

  Widget _buildKidneyLoadGauge(BuildContext context, bool isDesktop) {
    final kidneyColor = _getKidneyLoadColor();
    
    return AnimatedContainer(
      duration: DesignConstants.animationNormal,
      padding: EdgeInsets.all(isDesktop ? DesignConstants.spacingL : DesignConstants.spacingM),
      decoration: BoxDecoration(
        color: kidneyColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignConstants.radiusM),
        border: Border.all(
          color: kidneyColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignConstants.spacingXS),
                decoration: BoxDecoration(
                  color: kidneyColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DesignConstants.spacingXS),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: kidneyColor,
                  size: isDesktop ? 20 : 16,
                ),
              ),
              SizedBox(width: PlatformUtils.getPlatformSpacing(context) * 0.5),
              Expanded(
                child: Text(
                  'Kidney Load: ${widget.kidneyLoad.round()}%',
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontCaption),
                    color: kidneyColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _getKidneyLoadStatus(),
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontSmall),
                  color: kidneyColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          SizedBox(height: PlatformUtils.getPlatformSpacing(context) * 0.5),
          Container(
            height: isDesktop ? 8 : 6,
            decoration: BoxDecoration(
              color: DesignConstants.cupRim,
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedContainer(
              duration: DesignConstants.animationNormal,
              width: MediaQuery.of(context).size.width * (widget.kidneyLoad / 100).clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: kidneyColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getKidneyLoadColor() {
    if (widget.kidneyLoad >= 85) return Colors.red;
    if (widget.kidneyLoad >= 70) return DesignConstants.warning;
    if (widget.kidneyLoad >= 50) return Colors.orange;
    return DesignConstants.success;
  }

  String _getKidneyLoadStatus() {
    if (widget.kidneyLoad >= 85) return 'Critical';
    if (widget.kidneyLoad >= 70) return 'High';
    if (widget.kidneyLoad >= 50) return 'Elevated';
    return 'Normal';
  }

  Widget _buildDetailedStats(BuildContext context, bool isDesktop) {
    final safetyData = widget.enhancedSafetyData!;
    
    return Container(
      padding: EdgeInsets.all(isDesktop ? DesignConstants.spacingL : DesignConstants.spacingM),
      decoration: BoxDecoration(
        color: DesignConstants.milkTeaBeige.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(DesignConstants.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Health Stats',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontSubtitle),
              fontWeight: FontWeight.bold,
              color: DesignConstants.textPrimary,
            ),
          ),
          SizedBox(height: PlatformUtils.getPlatformSpacing(context) * 0.5),
          Row(
            children: [
              _buildStatItem('Hourly Rate', '${safetyData['hourlyRate']?.round() ?? 0}ml/hr'),
              const Spacer(),
              _buildStatItem('Health Status', safetyData['isHealthyRate'] == true ? 'Optimal' : 'Monitor'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: DesignConstants.fontSmall,
            color: DesignConstants.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: DesignConstants.fontCaption,
            fontWeight: FontWeight.w600,
            color: DesignConstants.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyWarning(BuildContext context, bool isDesktop) {
    final warning = widget.currentWarning!;
    
    return AnimatedContainer(
      duration: DesignConstants.animationNormal,
      padding: EdgeInsets.all(isDesktop ? DesignConstants.spacingL : DesignConstants.spacingM),
      decoration: BoxDecoration(
        color: warning.warningColor?.withValues(alpha: 0.1) ?? DesignConstants.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignConstants.radiusM),
        border: Border.all(
          color: warning.warningColor?.withValues(alpha: 0.4) ?? DesignConstants.warning.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                warning.level == SafetyLevel.danger ? Icons.warning : Icons.info,
                color: warning.warningColor,
                size: isDesktop ? 24 : 20,
              ),
              SizedBox(width: PlatformUtils.getPlatformSpacing(context) * 0.5),
              Expanded(
                child: Text(
                  warning.title,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontSubtitle),
                    fontWeight: FontWeight.bold,
                    color: warning.warningColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: PlatformUtils.getPlatformSpacing(context) * 0.5),
          Text(
            warning.message,
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: PlatformUtils.getResponsiveFontSize(context, DesignConstants.fontBody),
              color: DesignConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}