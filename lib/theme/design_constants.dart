import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';

/// Design constants for the Sipster app following the boba tea aesthetic
class DesignConstants {
  // Bubble Tea Inspired Color Palette
  static const Color taroPurple = Color(0xFFB794F6);
  static const Color milkTeaBeige = Color(0xFFFDF2E9);
  static const Color matchaGreen = Color(0xFF9AE6B4);
  static const Color brownSugar = Color(0xFFD69E2E);
  static const Color strawberryPink = Color(0xFFFBB6CE);
  static const Color thaiTeaOrange = Color(0xFFFBD38D);
  
  // Supporting Colors
  static const Color pearlWhite = Color(0xFFFFFFFF);
  static const Color tapiocaBlack = Color(0xFF2D3748);
  static const Color steamGray = Color(0xFF718096);
  static const Color cupRim = Color(0xFFE2E8F0);
  
  // Semantic Colors
  static const Color primary = taroPurple;
  static const Color secondary = milkTeaBeige;
  static const Color success = matchaGreen;
  static const Color warning = brownSugar;
  static const Color accent = strawberryPink;
  static const Color celebration = thaiTeaOrange;
  
  // Text Colors
  static const Color textPrimary = tapiocaBlack;
  static const Color textSecondary = steamGray;
  
  // Background Colors
  static const Color backgroundPrimary = pearlWhite;
  static const Color backgroundSecondary = milkTeaBeige;
  
  // Border Colors
  static const Color borderLight = cupRim;
  static const Color borderPrimary = primary;
  
  // Typography Scale (friendly & rounded with platform scaling)
  static const double fontHero = 28.0;
  static const double fontHeroDesktop = 36.0;
  static const double fontTitle = 20.0;
  static const double fontTitleDesktop = 24.0;
  static const double fontSubtitle = 16.0;
  static const double fontSubtitleDesktop = 18.0;
  static const double fontBody = 14.0;
  static const double fontBodyDesktop = 16.0;
  static const double fontCaption = 12.0;
  static const double fontCaptionDesktop = 14.0;
  static const double fontSmall = 10.0;
  static const double fontSmallDesktop = 12.0;
  
  // Line Heights
  static const double lineHeightHero = 1.2;
  static const double lineHeightTitle = 1.3;
  static const double lineHeightSubtitle = 1.4;
  static const double lineHeightBody = 1.5;
  static const double lineHeightCaption = 1.4;
  static const double lineHeightSmall = 1.3;
  
  // Spacing (with platform scaling)
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingHuge = 32.0;
  
  // Desktop spacing (20% larger for better touch targets)
  static const double spacingXSDesktop = 5.0;
  static const double spacingSDesktop = 10.0;
  static const double spacingMDesktop = 14.0;
  static const double spacingLDesktop = 20.0;
  static const double spacingXLDesktop = 24.0;
  static const double spacingXXLDesktop = 30.0;
  static const double spacingHugeDesktop = 40.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusPill = 28.0;
  
  // Component Heights (with platform variations)
  static const double headerHeight = 100.0;
  static const double headerHeightDesktop = 120.0;
  static const double characterDisplayHeight = 240.0;
  static const double characterDisplayHeightDesktop = 300.0;
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 48.0;
  static const double buttonHeightDesktop = 64.0;
  static const double buttonHeightDesktopSmall = 56.0;
  
  // Character Card Sizes (platform adaptive)
  static const double characterCardWidth = 80.0;
  static const double characterCardWidthTablet = 90.0;
  static const double characterCardWidthDesktop = 100.0;
  static const double characterCardHeight = 100.0;
  static const double characterCardHeightTablet = 110.0;
  static const double characterCardHeightDesktop = 120.0;
  static const double characterSpriteSize = 60.0;
  static const double characterSpriteSizeTablet = 70.0;
  static const double characterSpriteSizeDesktop = 80.0;
  
  // Elevation (platform specific)
  static const double elevationCard = 2.0;
  static const double elevationCardDesktop = 4.0;
  static const double elevationButton = 4.0;
  static const double elevationButtonDesktop = 2.0; // Less elevation on desktop
  static const double elevationModal = 8.0;
  static const double elevationModalDesktop = 16.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 600);
  
  // Gradients
  static LinearGradient get headerGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [milkTeaBeige, pearlWhite],
  );
  
  static LinearGradient get armyDisplayGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primary.withValues(alpha: 0.1),
      secondary.withValues(alpha: 0.05),
    ],
  );
  
  static LinearGradient get progressGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, success],
  );
  
  // Text Styles
  static const TextStyle heroStyle = TextStyle(
    fontSize: fontHero,
    height: lineHeightHero,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static const TextStyle titleStyle = TextStyle(
    fontSize: fontTitle,
    height: lineHeightTitle,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: fontSubtitle,
    height: lineHeightSubtitle,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: fontBody,
    height: lineHeightBody,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: fontCaption,
    height: lineHeightCaption,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );
  
  static const TextStyle smallStyle = TextStyle(
    fontSize: fontSmall,
    height: lineHeightSmall,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );
  
  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: pearlWhite,
    elevation: elevationButton,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusPill),
    ),
    minimumSize: const Size.fromHeight(buttonHeight),
    textStyle: const TextStyle(
      fontSize: fontSubtitle,
      fontWeight: FontWeight.w600,
    ),
  );
  
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: primary,
    side: const BorderSide(color: primary, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusPill),
    ),
    minimumSize: const Size.fromHeight(buttonHeight),
    textStyle: const TextStyle(
      fontSize: fontSubtitle,
      fontWeight: FontWeight.w600,
    ),
  );
  
  static ButtonStyle get successButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: success,
    foregroundColor: pearlWhite,
    elevation: elevationButton,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusPill),
    ),
    minimumSize: const Size.fromHeight(buttonHeight),
    textStyle: const TextStyle(
      fontSize: fontSubtitle,
      fontWeight: FontWeight.w600,
    ),
  );
  
  // Card Styles
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: backgroundPrimary,
    borderRadius: BorderRadius.circular(radiusL),
    boxShadow: [
      BoxShadow(
        color: tapiocaBlack.withValues(alpha: 0.1),
        blurRadius: elevationCard * 2,
        offset: Offset(0, elevationCard),
      ),
    ],
  );
  
  static BoxDecoration get characterCardDecoration => BoxDecoration(
    color: backgroundPrimary,
    borderRadius: BorderRadius.circular(radiusM),
    border: Border.all(color: borderLight),
  );
  
  // Army Status Colors
  static Color getArmyStatusColor(String status) {
    if (status.toLowerCase().contains('happy') || status.toLowerCase().contains('perfect')) {
      return success;
    } else if (status.toLowerCase().contains('concerned') || status.toLowerCase().contains('behind')) {
      return warning;
    } else if (status.toLowerCase().contains('waterlogged') || status.toLowerCase().contains('over')) {
      return Colors.blue;
    }
    return textSecondary;
  }
  
  // Type Colors for Boba Characters
  static Color getBobaTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'taro':
        return taroPurple;
      case 'matcha':
        return matchaGreen;
      case 'fruit':
        return thaiTeaOrange;
      case 'milk_tea':
      case 'milktea':
        return Color(0xFF8B4513); // Saddle brown
      case 'classic':
        return steamGray;
      default:
        return primary;
    }
  }
  
  // Safety Warning Colors
  static Color getSafetyWarningColor(String warningLevel) {
    switch (warningLevel.toLowerCase()) {
      case 'high':
      case 'danger':
        return Colors.red;
      case 'medium':
      case 'warning':
        return warning;
      case 'low':
      case 'info':
        return Colors.blue;
      default:
        return textSecondary;
    }
  }
  
  // Error colors for different severity levels
  static const Color error = Color(0xFFE53E3E);
  static const Color errorLight = Color(0xFFFED7D7);
  static const Color errorDark = Color(0xFFC53030);
  
  // Platform-adaptive getters
  static double getHeaderHeight(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? headerHeightDesktop : headerHeight;
  }
  
  static double getButtonHeight(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? buttonHeightDesktop : buttonHeight;
  }
  
  static double getButtonHeightSmall(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? buttonHeightDesktopSmall : buttonHeightSmall;
  }
  
  static double getCharacterCardWidth(BuildContext context) {
    if (PlatformUtils.isDesktop(context)) return characterCardWidthDesktop;
    if (PlatformUtils.isTablet(context)) return characterCardWidthTablet;
    return characterCardWidth;
  }
  
  static double getCharacterCardHeight(BuildContext context) {
    if (PlatformUtils.isDesktop(context)) return characterCardHeightDesktop;
    if (PlatformUtils.isTablet(context)) return characterCardHeightTablet;
    return characterCardHeight;
  }
  
  static double getCharacterSpriteSize(BuildContext context) {
    if (PlatformUtils.isDesktop(context)) return characterSpriteSizeDesktop;
    if (PlatformUtils.isTablet(context)) return characterSpriteSizeTablet;
    return characterSpriteSize;
  }
  
  static double getElevationCard(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? elevationCardDesktop : elevationCard;
  }
  
  static double getElevationButton(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? elevationButtonDesktop : elevationButton;
  }
  
  static double getElevationModal(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? elevationModalDesktop : elevationModal;
  }
  
  // Platform-adaptive font sizes
  static double getFontHero(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? fontHeroDesktop : fontHero;
  }
  
  static double getFontTitle(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? fontTitleDesktop : fontTitle;
  }
  
  static double getFontSubtitle(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? fontSubtitleDesktop : fontSubtitle;
  }
  
  static double getFontBody(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? fontBodyDesktop : fontBody;
  }
  
  static double getFontCaption(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? fontCaptionDesktop : fontCaption;
  }
  
  static double getFontSmall(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? fontSmallDesktop : fontSmall;
  }
  
  // Platform-adaptive spacing
  static double getSpacingXS(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? spacingXSDesktop : spacingXS;
  }
  
  static double getSpacingS(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? spacingSDesktop : spacingS;
  }
  
  static double getSpacingM(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? spacingMDesktop : spacingM;
  }
  
  static double getSpacingL(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? spacingLDesktop : spacingL;
  }
  
  static double getSpacingXL(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? spacingXLDesktop : spacingXL;
  }
  
  static double getSpacingXXL(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? spacingXXLDesktop : spacingXXL;
  }
  
  static double getSpacingHuge(BuildContext context) {
    return PlatformUtils.isDesktop(context) ? spacingHugeDesktop : spacingHuge;
  }
}