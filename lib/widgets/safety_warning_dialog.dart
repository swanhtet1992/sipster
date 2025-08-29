import 'package:flutter/material.dart';
import '../models/safety_warning.dart';
import '../theme/design_constants.dart';
import '../utils/platform_utils.dart';

class SafetyWarningDialog extends StatelessWidget {
  final SafetyWarning warning;
  final VoidCallback? onDismiss;
  final VoidCallback? onPause;
  final VoidCallback? onContinue;

  const SafetyWarningDialog({
    super.key,
    required this.warning,
    this.onDismiss,
    this.onPause,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformUtils.isDesktop(context);
    
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          isDesktop ? DesignConstants.radiusL : DesignConstants.radiusM,
        ),
        side: BorderSide(
          color: _getWarningColor().withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      title: _buildHeader(context, isDesktop),
      content: _buildContent(context, isDesktop),
      actions: [_buildActions(context, isDesktop)],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isDesktop ? DesignConstants.spacingXL : DesignConstants.spacingL,
      ),
      decoration: BoxDecoration(
        color: _getWarningColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            isDesktop ? DesignConstants.radiusL : DesignConstants.radiusM,
          ),
          topRight: Radius.circular(
            isDesktop ? DesignConstants.radiusL : DesignConstants.radiusM,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DesignConstants.spacingS),
            decoration: BoxDecoration(
              color: _getWarningColor().withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getWarningIcon(),
              color: _getWarningColor(),
              size: isDesktop ? 28 : 24,
            ),
          ),
          const SizedBox(width: DesignConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWarningTypeLabel(),
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: isDesktop ? 12 : 10,
                    fontWeight: FontWeight.w600,
                    color: _getWarningColor(),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  warning.title,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: isDesktop ? DesignConstants.fontTitle : DesignConstants.fontSubtitle,
                    fontWeight: FontWeight.bold,
                    color: DesignConstants.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDesktop) {
    return Container(
      width: isDesktop ? 500 : double.infinity,
      padding: EdgeInsets.all(
        isDesktop ? DesignConstants.spacingXL : DesignConstants.spacingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            warning.message,
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: isDesktop ? DesignConstants.fontSubtitle : DesignConstants.fontBody,
              height: 1.5,
              color: DesignConstants.textPrimary,
            ),
          ),
          
          if (warning.suggestedDelay != null) ...[
            const SizedBox(height: DesignConstants.spacingL),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignConstants.spacingM),
              decoration: BoxDecoration(
                color: DesignConstants.milkTeaBeige.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(DesignConstants.radiusS),
                border: Border.all(
                  color: DesignConstants.milkTeaBeige.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: DesignConstants.primary,
                        size: isDesktop ? 20 : 18,
                      ),
                      const SizedBox(width: DesignConstants.spacingS),
                      Text(
                        'Recommended Wait Time',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: isDesktop ? DesignConstants.fontBody : DesignConstants.fontSmall,
                          fontWeight: FontWeight.w600,
                          color: DesignConstants.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignConstants.spacingS),
                  Text(
                    _formatDuration(warning.suggestedDelay!),
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: isDesktop ? DesignConstants.fontSubtitle : DesignConstants.fontBody,
                      fontWeight: FontWeight.bold,
                      color: DesignConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Give your body time to process fluids safely',
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: isDesktop ? DesignConstants.fontSmall : DesignConstants.fontCaption,
                      color: DesignConstants.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_shouldShowExtraInfo()) ...[
            const SizedBox(height: DesignConstants.spacingL),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(DesignConstants.spacingM),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(DesignConstants.radiusS),
                border: Border.all(
                  color: Colors.blue.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: isDesktop ? 20 : 18,
                      ),
                      const SizedBox(width: DesignConstants.spacingS),
                      Text(
                        'Hydration Safety Tips',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: isDesktop ? DesignConstants.fontBody : DesignConstants.fontSmall,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignConstants.spacingS),
                  ..._getExtraInfoTips().map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: isDesktop ? DesignConstants.fontBody : DesignConstants.fontSmall,
                          ),
                        ),
                        const SizedBox(width: DesignConstants.spacingS),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: isDesktop ? DesignConstants.fontSmall : DesignConstants.fontCaption,
                              color: DesignConstants.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isDesktop ? DesignConstants.spacingL : DesignConstants.spacingM,
      ),
      child: isDesktop 
          ? _buildDesktopActions(context)
          : _buildMobileActions(context),
    );
  }

  Widget _buildDesktopActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onDismiss != null && warning.level != SafetyLevel.danger) ...[
          TextButton(
            onPressed: onDismiss,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignConstants.spacingL,
                vertical: DesignConstants.spacingM,
              ),
            ),
            child: Text(
              'I Understand (Esc)',
              style: TextStyle(
                fontSize: DesignConstants.fontBody,
                color: DesignConstants.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: DesignConstants.spacingM),
        ],
        if (onPause != null && warning.level == SafetyLevel.warning) ...[
          OutlinedButton(
            onPressed: onPause,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignConstants.spacingL,
                vertical: DesignConstants.spacingM,
              ),
              side: BorderSide(color: _getWarningColor()),
            ),
            child: Text(
              'Pause Session (P)',
              style: TextStyle(
                fontSize: DesignConstants.fontBody,
                color: _getWarningColor(),
              ),
            ),
          ),
          const SizedBox(width: DesignConstants.spacingM),
        ],
        ElevatedButton(
          onPressed: onContinue ?? () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getWarningColor(),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignConstants.spacingXL,
              vertical: DesignConstants.spacingM,
            ),
          ),
          child: Text(
            _getPrimaryActionLabel(),
            style: const TextStyle(
              fontSize: DesignConstants.fontBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileActions(BuildContext context) {
    return Column(
      children: [
        if (onPause != null && warning.level == SafetyLevel.warning) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onPause,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: DesignConstants.spacingM),
                side: BorderSide(color: _getWarningColor()),
              ),
              child: Text(
                'Pause Session',
                style: TextStyle(
                  fontSize: DesignConstants.fontBody,
                  color: _getWarningColor(),
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignConstants.spacingS),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue ?? () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getWarningColor(),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: DesignConstants.spacingM),
            ),
            child: Text(
              _getPrimaryActionLabel(),
              style: const TextStyle(
                fontSize: DesignConstants.fontBody,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (onDismiss != null && warning.level != SafetyLevel.danger) ...[
          const SizedBox(height: DesignConstants.spacingS),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onDismiss,
              child: const Text('I Understand'),
            ),
          ),
        ],
      ],
    );
  }

  Color _getWarningColor() {
    switch (warning.level) {
      case SafetyLevel.info:
        return Colors.blue.shade600;
      case SafetyLevel.warning:
        return DesignConstants.warning;
      case SafetyLevel.danger:
        return DesignConstants.error;
    }
  }

  IconData _getWarningIcon() {
    switch (warning.level) {
      case SafetyLevel.info:
        return Icons.info_outline;
      case SafetyLevel.warning:
        return Icons.warning_amber_outlined;
      case SafetyLevel.danger:
        return Icons.dangerous_outlined;
    }
  }

  String _getWarningTypeLabel() {
    switch (warning.level) {
      case SafetyLevel.info:
        return 'HYDRATION TIP';
      case SafetyLevel.warning:
        return 'CAUTION';
      case SafetyLevel.danger:
        return 'CRITICAL WARNING';
    }
  }

  String _getPrimaryActionLabel() {
    switch (warning.level) {
      case SafetyLevel.info:
        return 'Got It';
      case SafetyLevel.warning:
        return 'Understood';
      case SafetyLevel.danger:
        return 'Stop Session';
    }
  }

  bool _shouldShowExtraInfo() {
    return warning.level == SafetyLevel.warning || 
           warning.level == SafetyLevel.danger;
  }

  List<String> _getExtraInfoTips() {
    switch (warning.level) {
      case SafetyLevel.warning:
        return [
          'Drinking too much too fast can strain your kidneys',
          'Space out your hydration throughout the day',
          'Listen to your body - thirst is a natural guide',
        ];
      case SafetyLevel.danger:
        return [
          'Water intoxication can be dangerous',
          'Symptoms include nausea, headache, confusion',
          'Stop drinking immediately and rest',
          'Consult a healthcare provider if symptoms persist',
        ];
      default:
        return [];
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required SafetyWarning warning,
    VoidCallback? onDismiss,
    VoidCallback? onPause,
    VoidCallback? onContinue,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: warning.level != SafetyLevel.danger,
      builder: (context) => SafetyWarningDialog(
        warning: warning,
        onDismiss: onDismiss,
        onPause: onPause,
        onContinue: onContinue,
      ),
    );
  }
}