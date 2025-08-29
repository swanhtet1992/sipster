import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// Platform detection and responsive utilities for Sipster app
class PlatformUtils {
  // Responsive breakpoints for different screen sizes
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1024;

  /// Check if the current platform is mobile (phone)
  static bool isMobile(BuildContext context) {
    if (kIsWeb) {
      return MediaQuery.of(context).size.width < mobileMaxWidth;
    }
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Check if the current platform is tablet
  static bool isTablet(BuildContext context) {
    if (kIsWeb) {
      final width = MediaQuery.of(context).size.width;
      return width >= mobileMaxWidth && width < desktopMinWidth;
    }
    // For native platforms, use screen size to determine tablet
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= 600; // Typical tablet threshold
  }

  /// Check if the current platform is desktop
  static bool isDesktop(BuildContext context) {
    if (kIsWeb) {
      return MediaQuery.of(context).size.width >= desktopMinWidth;
    }
    return Platform.isMacOS || Platform.isLinux || Platform.isWindows;
  }

  /// Get platform-appropriate padding based on screen size
  static EdgeInsets getPlatformPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get optimal character count for display based on platform
  static int getCharacterDisplayCount(BuildContext context) {
    if (isMobile(context)) {
      return 5; // 3-5 characters for mobile
    } else if (isTablet(context)) {
      return 8; // 6-10 characters for tablet
    } else {
      return 12; // 8-12 characters for desktop
    }
  }

  /// Get platform-specific button height
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 56.0; // Standard mobile touch target
    } else {
      return 48.0; // Slightly smaller for desktop/mouse interaction
    }
  }

  /// Get responsive grid cross axis count for character display
  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileMaxWidth) {
      return 3; // Mobile: 3 columns
    } else if (width < tabletMaxWidth) {
      return 4; // Tablet: 4 columns
    } else {
      return 6; // Desktop: 6 columns
    }
  }

  /// Get platform-specific character card size
  static double getCharacterCardSize(BuildContext context) {
    if (isMobile(context)) {
      return 80.0; // Larger for touch interaction
    } else {
      return 70.0; // Slightly smaller for desktop
    }
  }

  /// Check if the platform supports hover interactions
  static bool supportsHover(BuildContext context) {
    return isDesktop(context) && !kIsWeb;
  }

  /// Get responsive font size based on platform
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final textScaler = MediaQuery.of(context).textScaler;
    
    if (isMobile(context)) {
      return textScaler.scale(baseFontSize);
    } else if (isTablet(context)) {
      return textScaler.scale(baseFontSize * 1.1); // Slightly larger for tablets
    } else {
      return textScaler.scale(baseFontSize * 1.2); // Larger for desktop
    }
  }

  /// Get platform-specific maximum dialog width
  static double getMaxDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth * 0.9; // 90% of screen width on mobile
    } else if (isTablet(context)) {
      return 500; // Fixed width for tablets
    } else {
      return 600; // Larger fixed width for desktop
    }
  }

  /// Get platform name as string for debugging/logging
  static String getPlatformName() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isLinux) {
      return 'linux';
    } else {
      return 'unknown';
    }
  }

  /// Check if platform supports native notifications
  static bool supportsNativeNotifications() {
    if (kIsWeb) {
      return false; // Web notifications handled differently
    }
    return Platform.isAndroid || Platform.isIOS || 
           Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  /// Get platform-specific spacing between UI elements
  static double getPlatformSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 20.0;
    }
  }
}