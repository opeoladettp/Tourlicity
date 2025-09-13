import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // Surface Colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFB00020);

  // Text Colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Color(0xFF121212);
  static const Color onSurface = Color(0xFF121212);
  static const Color onError = Colors.white;

  // High Contrast Colors
  static const Color highContrastPrimary = Color(0xFF000080);
  static const Color highContrastSecondary = Color(0xFF008080);
  static const Color highContrastBackground = Colors.white;
  static const Color highContrastSurface = Colors.white;
  static const Color highContrastOnPrimary = Colors.white;
  static const Color highContrastOnSecondary = Colors.white;
  static const Color highContrastOnBackground = Colors.black;
  static const Color highContrastOnSurface = Colors.black;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Accessibility constants
  static const double minTouchTargetSize = 48.0;
  static const double accessibleFontSize = 16.0;
  static const double accessibleLineHeight = 1.5;

  static ThemeData get lightTheme {
    return _buildTheme(false, false);
  }

  static ThemeData get highContrastLightTheme {
    return _buildTheme(false, true);
  }

  static ThemeData _buildTheme(bool isDark, bool isHighContrast) {
    final colorScheme = _getColorScheme(isDark, isHighContrast);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Accessibility-focused text theme
      textTheme: _buildTextTheme(colorScheme),
      // Enhanced app bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
          height: accessibleLineHeight,
        ),
      ),
      // Accessible button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(minTouchTargetSize, minTouchTargetSize),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: accessibleFontSize,
            fontWeight: FontWeight.w600,
            height: accessibleLineHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isHighContrast ? BorderSide(
              color: colorScheme.outline,
              width: 2,
            ) : BorderSide.none,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(minTouchTargetSize, minTouchTargetSize),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: accessibleFontSize,
            fontWeight: FontWeight.w500,
            height: accessibleLineHeight,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(minTouchTargetSize, minTouchTargetSize),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: accessibleFontSize,
            fontWeight: FontWeight.w600,
            height: accessibleLineHeight,
          ),
          side: BorderSide(
            color: colorScheme.primary,
            width: isHighContrast ? 3 : 2,
          ),
        ),
      ),
      // Accessible input decoration
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: isHighContrast ? 2 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: isHighContrast ? 4 : 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: isHighContrast ? 3 : 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(
          fontSize: accessibleFontSize,
          height: accessibleLineHeight,
          color: colorScheme.onSurfaceVariant,
        ),
        helperStyle: TextStyle(
          fontSize: 14,
          height: accessibleLineHeight,
          color: colorScheme.onSurfaceVariant,
        ),
        errorStyle: TextStyle(
          fontSize: 14,
          height: accessibleLineHeight,
          color: colorScheme.error,
          fontWeight: FontWeight.w500,
        ),
      ),
      // Enhanced card theme
      cardTheme: CardThemeData(
        elevation: isHighContrast ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isHighContrast ? BorderSide(
            color: colorScheme.outline,
            width: 2,
          ) : BorderSide.none,
        ),
        margin: const EdgeInsets.all(8),
      ),
      // List tile theme for better accessibility
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TextStyle(
          fontSize: accessibleFontSize,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          height: accessibleLineHeight,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
          height: accessibleLineHeight,
        ),
      ),
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: accessibleLineHeight,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: accessibleLineHeight,
        ),
        elevation: isHighContrast ? 0 : 8,
      ),
      // Navigation drawer theme
      drawerTheme: DrawerThemeData(
        elevation: isHighContrast ? 0 : 16,
        shape: isHighContrast ? const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 2),
        ) : null,
      ),
      // Divider theme for better contrast
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: isHighContrast ? 2 : 1,
        space: isHighContrast ? 2 : 1,
      ),
      // Focus theme for keyboard navigation
      focusColor: colorScheme.primary.withValues(alpha: 0.12),
      hoverColor: colorScheme.primary.withValues(alpha: 0.08),
    );
  }

  static ColorScheme _getColorScheme(bool isDark, bool isHighContrast) {
    if (isHighContrast) {
      return isDark
          ? const ColorScheme.dark(
              primary: Colors.white,
              primaryContainer: Color(0xFF333333),
              secondary: Colors.yellow,
              secondaryContainer: Color(0xFF444400),
              surface: Colors.black,
              surfaceContainerHighest: Color(0xFF1A1A1A),
              error: Color(0xFFFF6B6B),
              errorContainer: Color(0xFF330000),
              onPrimary: Colors.black,
              onPrimaryContainer: Colors.white,
              onSecondary: Colors.black,
              onSecondaryContainer: Colors.yellow,
              onSurface: Colors.white,
              onSurfaceVariant: Colors.white,
              onError: Colors.white,
              onErrorContainer: Color(0xFFFF6B6B),
              outline: Colors.white,
              outlineVariant: Color(0xFFCCCCCC),
              shadow: Colors.white,
              scrim: Colors.white,
              inverseSurface: Colors.white,
              onInverseSurface: Colors.black,
              inversePrimary: Colors.black,
            )
          : const ColorScheme.light(
              primary: Colors.black,
              primaryContainer: Color(0xFFE0E0E0),
              secondary: Color(0xFF0066CC),
              secondaryContainer: Color(0xFFCCE5FF),
              surface: Colors.white,
              surfaceContainerHighest: Color(0xFFF5F5F5),
              error: Color(0xFFCC0000),
              errorContainer: Color(0xFFFFE6E6),
              onPrimary: Colors.white,
              onPrimaryContainer: Colors.black,
              onSecondary: Colors.white,
              onSecondaryContainer: Color(0xFF0066CC),
              onSurface: Colors.black,
              onSurfaceVariant: Colors.black,
              onError: Colors.white,
              onErrorContainer: Color(0xFFCC0000),
              outline: Colors.black,
              outlineVariant: Color(0xFF666666),
              shadow: Colors.black,
              scrim: Colors.black,
              inverseSurface: Colors.black,
              onInverseSurface: Colors.white,
              inversePrimary: Colors.white,
            );
    }

    return isDark
        ? const ColorScheme.dark(
            primary: primaryColor,
            secondary: secondaryColor,
            surface: Color(0xFF121212),
            error: errorColor,
            onPrimary: onPrimary,
            onSecondary: onSecondary,
            onSurface: Colors.white,
            onError: onError,
          )
        : const ColorScheme.light(
            primary: primaryColor,
            secondary: secondaryColor,
            surface: surfaceColor,
            error: errorColor,
            onPrimary: onPrimary,
            onSecondary: onSecondary,
            onSurface: onSurface,
            onError: onError,
          );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      titleLarge: TextStyle(
        fontSize: accessibleFontSize + 2,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      titleMedium: TextStyle(
        fontSize: accessibleFontSize,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      bodyLarge: TextStyle(
        fontSize: accessibleFontSize,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        height: accessibleLineHeight,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        height: accessibleLineHeight,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
        height: accessibleLineHeight,
      ),
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(true, false);
  }

  static ThemeData get highContrastDarkTheme {
    return _buildTheme(true, true);
  }

  // Helper method to determine if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  // Helper method to determine if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  // Helper method to determine if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  // Get responsive column count for grids
  static int getResponsiveColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  // Get responsive max width for content
  static double getResponsiveMaxWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return screenWidth;
    } else if (isTablet(context)) {
      return screenWidth * 0.8;
    } else {
      return 1200;
    }
  }

  // Get accessible text scale factor
  static double getAccessibleTextScale(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.textScaler.scale(1.0);
  }

  // Check if reduced motion is preferred
  static bool isReducedMotionPreferred(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  // Get animation duration based on accessibility preferences
  static Duration getAnimationDuration(BuildContext context, Duration defaultDuration) {
    if (isReducedMotionPreferred(context)) {
      return Duration.zero;
    }
    return defaultDuration;
  }

  // Get accessible focus border width
  static double getFocusBorderWidth(BuildContext context, {bool isHighContrast = false}) {
    final mediaQuery = MediaQuery.of(context);
    final baseWidth = isHighContrast ? 4.0 : 2.0;
    return baseWidth * mediaQuery.textScaler.scale(1.0);
  }

  // Get accessible spacing based on text scale
  static double getAccessibleSpacing(BuildContext context, double baseSpacing) {
    final textScale = getAccessibleTextScale(context);
    return baseSpacing * textScale.clamp(1.0, 1.5);
  }

  // Check if high contrast is enabled system-wide
  static bool isSystemHighContrastEnabled(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  // Get accessible color contrast ratio
  static Color getAccessibleColor(Color foreground, Color background, {double minContrast = 4.5}) {
    // Simple contrast calculation - in production, use a proper contrast library
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    
    final contrast = (foregroundLuminance + 0.05) / (backgroundLuminance + 0.05);
    
    if (contrast < minContrast) {
      // Return a high contrast alternative
      return backgroundLuminance > 0.5 ? Colors.black : Colors.white;
    }
    
    return foreground;
  }

  // Get semantic colors for different states
  static Color getSemanticColor(BuildContext context, SemanticColorType type) {
    final theme = Theme.of(context);
    final isHighContrast = MediaQuery.of(context).highContrast;
    
    switch (type) {
      case SemanticColorType.success:
        return isHighContrast ? const Color(0xFF00AA00) : Colors.green;
      case SemanticColorType.warning:
        return isHighContrast ? const Color(0xFFFF8800) : Colors.orange;
      case SemanticColorType.error:
        return isHighContrast ? const Color(0xFFCC0000) : theme.colorScheme.error;
      case SemanticColorType.info:
        return isHighContrast ? const Color(0xFF0066CC) : Colors.blue;
    }
  }
}

enum SemanticColorType {
  success,
  warning,
  error,
  info,
}
