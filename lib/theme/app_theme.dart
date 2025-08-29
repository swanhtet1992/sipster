import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_constants.dart';
import '../utils/platform_utils.dart';

class AppTheme {
  static ThemeData getLightTheme(BuildContext context) {
    final isDesktop = PlatformUtils.isDesktop(context);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _createMaterialColor(DesignConstants.primary),
        backgroundColor: DesignConstants.backgroundPrimary,
        brightness: Brightness.light,
      ).copyWith(
        primary: DesignConstants.primary,
        secondary: DesignConstants.secondary,
        surface: DesignConstants.backgroundPrimary,
        onPrimary: DesignConstants.pearlWhite,
        onSecondary: DesignConstants.textPrimary,
        onSurface: DesignConstants.textPrimary,
        error: DesignConstants.error,
        onError: DesignConstants.pearlWhite,
        outline: DesignConstants.borderLight,
        shadow: DesignConstants.tapiocaBlack.withValues(alpha: 0.1),
      ),
      
      // Platform-specific visual density
      visualDensity: isDesktop 
          ? VisualDensity.comfortable
          : VisualDensity.adaptivePlatformDensity,
      
      // Typography
      textTheme: _buildTextTheme(context),
      primaryTextTheme: _buildTextTheme(context),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: DesignConstants.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: DesignConstants.getFontTitle(context),
          fontWeight: FontWeight.bold,
          color: DesignConstants.textPrimary,
          fontFamily: 'SF Pro Display',
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: DesignConstants.backgroundPrimary,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      
      // Scaffold Theme
      scaffoldBackgroundColor: DesignConstants.backgroundPrimary,
      
      // Card Theme
      cardTheme: CardTheme(
        color: DesignConstants.backgroundPrimary,
        elevation: DesignConstants.getElevationCard(context),
        shadowColor: DesignConstants.tapiocaBlack.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.radiusL),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.all(DesignConstants.getSpacingS(context)),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buildElevatedButtonStyle(context),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buildOutlinedButtonStyle(context),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: _buildTextButtonStyle(context),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: _buildInputDecorationTheme(context),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: DesignConstants.backgroundPrimary,
        elevation: DesignConstants.getElevationModal(context),
        shadowColor: DesignConstants.tapiocaBlack.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            isDesktop ? DesignConstants.radiusXL : DesignConstants.radiusL,
          ),
        ),
        titleTextStyle: TextStyle(
          fontSize: DesignConstants.getFontTitle(context),
          fontWeight: FontWeight.bold,
          color: DesignConstants.textPrimary,
          fontFamily: 'SF Pro Display',
        ),
        contentTextStyle: TextStyle(
          fontSize: DesignConstants.getFontBody(context),
          color: DesignConstants.textPrimary,
          height: 1.5,
          fontFamily: 'SF Pro Text',
        ),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignConstants.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(DesignConstants.pearlWhite),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.radiusS / 2),
        ),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignConstants.primary;
          }
          return DesignConstants.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignConstants.primary.withValues(alpha: 0.3);
          }
          return DesignConstants.borderLight;
        }),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: DesignConstants.primary,
        inactiveTrackColor: DesignConstants.borderLight,
        thumbColor: DesignConstants.primary,
        overlayColor: DesignConstants.primary.withValues(alpha: 0.2),
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: isDesktop ? 12 : 10,
        ),
        overlayShape: RoundSliderOverlayShape(
          overlayRadius: isDesktop ? 24 : 20,
        ),
      ),
      
      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignConstants.getSpacingL(context),
          vertical: DesignConstants.getSpacingS(context),
        ),
        titleTextStyle: TextStyle(
          fontSize: DesignConstants.getFontBody(context),
          fontWeight: FontWeight.w500,
          color: DesignConstants.textPrimary,
          fontFamily: 'SF Pro Text',
        ),
        subtitleTextStyle: TextStyle(
          fontSize: DesignConstants.getFontCaption(context),
          color: DesignConstants.textSecondary,
          fontFamily: 'SF Pro Text',
        ),
        iconColor: DesignConstants.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.radiusM),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: DesignConstants.primary.withValues(alpha: 0.1),
        horizontalTitleGap: DesignConstants.getSpacingM(context),
        minVerticalPadding: DesignConstants.getSpacingS(context),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: DesignConstants.secondary,
        selectedColor: DesignConstants.primary,
        disabledColor: DesignConstants.borderLight,
        labelStyle: TextStyle(
          fontSize: DesignConstants.getFontCaption(context),
          fontWeight: FontWeight.w500,
          color: DesignConstants.textPrimary,
          fontFamily: 'SF Pro Text',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignConstants.radiusPill),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: DesignConstants.getSpacingM(context),
          vertical: DesignConstants.getSpacingS(context),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(BuildContext context) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: DesignConstants.getFontHero(context),
        fontWeight: FontWeight.bold,
        color: DesignConstants.textPrimary,
        height: DesignConstants.lineHeightHero,
        fontFamily: 'SF Pro Display',
      ),
      displayMedium: TextStyle(
        fontSize: DesignConstants.getFontTitle(context),
        fontWeight: FontWeight.bold,
        color: DesignConstants.textPrimary,
        height: DesignConstants.lineHeightTitle,
        fontFamily: 'SF Pro Display',
      ),
      displaySmall: TextStyle(
        fontSize: DesignConstants.getFontSubtitle(context),
        fontWeight: FontWeight.w600,
        color: DesignConstants.textPrimary,
        height: DesignConstants.lineHeightSubtitle,
        fontFamily: 'SF Pro Display',
      ),
      headlineLarge: TextStyle(
        fontSize: DesignConstants.getFontTitle(context),
        fontWeight: FontWeight.bold,
        color: DesignConstants.textPrimary,
        height: DesignConstants.lineHeightTitle,
        fontFamily: 'SF Pro Display',
      ),
      headlineMedium: TextStyle(
        fontSize: DesignConstants.getFontSubtitle(context),
        fontWeight: FontWeight.w600,
        color: DesignConstants.textPrimary,
        height: DesignConstants.lineHeightSubtitle,
        fontFamily: 'SF Pro Display',
      ),
      headlineSmall: TextStyle(
        fontSize: DesignConstants.getFontBody(context),
        fontWeight: FontWeight.w600,
        color: DesignConstants.textPrimary,
        height: DesignConstants.lineHeightBody,
        fontFamily: 'SF Pro Display',
      ),
      titleLarge: TextStyle(
        fontSize: DesignConstants.getFontTitle(context),
        fontWeight: FontWeight.w600,
        color: DesignConstants.textPrimary,
        height: DesignConstants.lineHeightTitle,
        fontFamily: 'SF Pro Display',
      ),
      titleMedium: TextStyle(
        fontSize: DesignConstants.getFontSubtitle(context),
        fontWeight: FontWeight.w500,
        color: DesignConstants.textPrimary,
        height: DesignConstants.lineHeightSubtitle,
        fontFamily: 'SF Pro Display',
      ),
      titleSmall: TextStyle(
        fontSize: DesignConstants.getFontBody(context),
        fontWeight: FontWeight.w500,
        color: DesignConstants.textPrimary,
        height: DesignConstants.lineHeightBody,
        fontFamily: 'SF Pro Display',
      ),
      bodyLarge: TextStyle(
        fontSize: DesignConstants.getFontSubtitle(context),
        fontWeight: FontWeight.normal,
        color: DesignConstants.textPrimary,
        height: DesignConstants.lineHeightSubtitle,
        fontFamily: 'SF Pro Text',
      ),
      bodyMedium: TextStyle(
        fontSize: DesignConstants.getFontBody(context),
        fontWeight: FontWeight.normal,
        color: DesignConstants.textPrimary,
        height: DesignConstants.lineHeightBody,
        fontFamily: 'SF Pro Text',
      ),
      bodySmall: TextStyle(
        fontSize: DesignConstants.getFontCaption(context),
        fontWeight: FontWeight.normal,
        color: DesignConstants.textSecondary,
        height: DesignConstants.lineHeightCaption,
        fontFamily: 'SF Pro Text',
      ),
      labelLarge: TextStyle(
        fontSize: DesignConstants.getFontBody(context),
        fontWeight: FontWeight.w500,
        color: DesignConstants.textPrimary,
        fontFamily: 'SF Pro Text',
      ),
      labelMedium: TextStyle(
        fontSize: DesignConstants.getFontCaption(context),
        fontWeight: FontWeight.w500,
        color: DesignConstants.textPrimary,
        fontFamily: 'SF Pro Text',
      ),
      labelSmall: TextStyle(
        fontSize: DesignConstants.getFontSmall(context),
        fontWeight: FontWeight.w500,
        color: DesignConstants.textSecondary,
        fontFamily: 'SF Pro Text',
      ),
    );
  }

  static ButtonStyle _buildElevatedButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: DesignConstants.primary,
      foregroundColor: DesignConstants.pearlWhite,
      elevation: DesignConstants.getElevationButton(context),
      shadowColor: DesignConstants.tapiocaBlack.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignConstants.radiusPill),
      ),
      minimumSize: Size.fromHeight(DesignConstants.getButtonHeight(context)),
      padding: EdgeInsets.symmetric(
        horizontal: DesignConstants.getSpacingL(context),
        vertical: DesignConstants.getSpacingM(context),
      ),
      textStyle: TextStyle(
        fontSize: DesignConstants.getFontSubtitle(context),
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return DesignConstants.pearlWhite.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.pressed)) {
          return DesignConstants.pearlWhite.withValues(alpha: 0.2);
        }
        return null;
      }),
    );
  }

  static ButtonStyle _buildOutlinedButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      foregroundColor: DesignConstants.primary,
      side: const BorderSide(color: DesignConstants.primary, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignConstants.radiusPill),
      ),
      minimumSize: Size.fromHeight(DesignConstants.getButtonHeight(context)),
      padding: EdgeInsets.symmetric(
        horizontal: DesignConstants.getSpacingL(context),
        vertical: DesignConstants.getSpacingM(context),
      ),
      textStyle: TextStyle(
        fontSize: DesignConstants.getFontSubtitle(context),
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return DesignConstants.primary.withValues(alpha: 0.05);
        }
        if (states.contains(WidgetState.pressed)) {
          return DesignConstants.primary.withValues(alpha: 0.1);
        }
        return null;
      }),
    );
  }

  static ButtonStyle _buildTextButtonStyle(BuildContext context) {
    return TextButton.styleFrom(
      foregroundColor: DesignConstants.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignConstants.radiusM),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: DesignConstants.getSpacingL(context),
        vertical: DesignConstants.getSpacingM(context),
      ),
      textStyle: TextStyle(
        fontSize: DesignConstants.getFontBody(context),
        fontWeight: FontWeight.w500,
        fontFamily: 'SF Pro Display',
      ),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return DesignConstants.primary.withValues(alpha: 0.05);
        }
        if (states.contains(WidgetState.pressed)) {
          return DesignConstants.primary.withValues(alpha: 0.1);
        }
        return null;
      }),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(BuildContext context) {
    return InputDecorationTheme(
      filled: true,
      fillColor: DesignConstants.backgroundPrimary,
      contentPadding: EdgeInsets.symmetric(
        horizontal: DesignConstants.getSpacingL(context),
        vertical: DesignConstants.getSpacingM(context),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignConstants.radiusM),
        borderSide: const BorderSide(color: DesignConstants.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignConstants.radiusM),
        borderSide: const BorderSide(color: DesignConstants.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignConstants.radiusM),
        borderSide: const BorderSide(color: DesignConstants.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignConstants.radiusM),
        borderSide: const BorderSide(color: DesignConstants.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignConstants.radiusM),
        borderSide: const BorderSide(color: DesignConstants.error, width: 2),
      ),
      labelStyle: TextStyle(
        fontSize: DesignConstants.getFontBody(context),
        color: DesignConstants.textSecondary,
        fontFamily: 'SF Pro Text',
      ),
      hintStyle: TextStyle(
        fontSize: DesignConstants.getFontBody(context),
        color: DesignConstants.textSecondary.withValues(alpha: 0.6),
        fontFamily: 'SF Pro Text',
      ),
      errorStyle: TextStyle(
        fontSize: DesignConstants.getFontCaption(context),
        color: DesignConstants.error,
        fontFamily: 'SF Pro Text',
      ),
      helperStyle: TextStyle(
        fontSize: DesignConstants.getFontCaption(context),
        color: DesignConstants.textSecondary,
        fontFamily: 'SF Pro Text',
      ),
      prefixIconColor: DesignConstants.textSecondary,
      suffixIconColor: DesignConstants.textSecondary,
      iconColor: DesignConstants.textSecondary,
    );
  }

  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.r.round(), g = color.g.round(), b = color.b.round();

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.toARGB32(), swatch);
  }
}