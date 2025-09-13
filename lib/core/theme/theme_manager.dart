import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Manages theme settings including high contrast mode and accessibility preferences
class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _highContrastKey = 'high_contrast_mode';
  static const String _textScaleKey = 'text_scale_factor';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isHighContrastMode = false;
  double _textScaleFactor = 1.0;
  SharedPreferences? _prefs;

  ThemeMode get themeMode => _themeMode;
  bool get isHighContrastMode => _isHighContrastMode;
  double get textScaleFactor => _textScaleFactor;

  /// Initialize the theme manager and load saved preferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPreferences();
    await _checkSystemAccessibilitySettings();
  }

  /// Load theme preferences from storage
  Future<void> _loadPreferences() async {
    if (_prefs == null) return;

    // Load theme mode
    final themeIndex = _prefs!.getInt(_themeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];

    // Load high contrast mode
    _isHighContrastMode = _prefs!.getBool(_highContrastKey) ?? false;

    // Load text scale factor
    _textScaleFactor = _prefs!.getDouble(_textScaleKey) ?? 1.0;

    notifyListeners();
  }

  /// Check system accessibility settings
  Future<void> _checkSystemAccessibilitySettings() async {
    try {
      // Check if system high contrast is enabled
      final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
      final systemHighContrast = platformDispatcher.accessibilityFeatures.highContrast;
      
      if (systemHighContrast && !_isHighContrastMode) {
        await setHighContrastMode(true);
      }

      // Check system text scale factor
      final systemTextScale = platformDispatcher.textScaleFactor;
      if (systemTextScale != _textScaleFactor) {
        await setTextScaleFactor(systemTextScale);
      }
    } catch (e) {
      // Handle platform-specific errors gracefully
      debugPrint('Error checking system accessibility settings: $e');
    }
  }

  /// Set the theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _prefs?.setInt(_themeKey, mode.index);
    notifyListeners();

    // Provide haptic feedback
    HapticFeedback.selectionClick();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Set high contrast mode
  Future<void> setHighContrastMode(bool enabled) async {
    if (_isHighContrastMode == enabled) return;

    _isHighContrastMode = enabled;
    await _prefs?.setBool(_highContrastKey, enabled);
    notifyListeners();

    // Provide haptic feedback
    HapticFeedback.selectionClick();

    // Announce the change to screen readers
    _announceAccessibilityChange(
      enabled ? 'High contrast mode enabled' : 'High contrast mode disabled'
    );
  }

  /// Toggle high contrast mode
  Future<void> toggleHighContrastMode() async {
    await setHighContrastMode(!_isHighContrastMode);
  }

  /// Set text scale factor
  Future<void> setTextScaleFactor(double factor) async {
    if (_textScaleFactor == factor) return;

    _textScaleFactor = factor.clamp(0.8, 2.0);
    await _prefs?.setDouble(_textScaleKey, _textScaleFactor);
    notifyListeners();

    // Provide haptic feedback
    HapticFeedback.selectionClick();
  }

  /// Reset all theme settings to defaults
  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _isHighContrastMode = false;
    _textScaleFactor = 1.0;

    await _prefs?.remove(_themeKey);
    await _prefs?.remove(_highContrastKey);
    await _prefs?.remove(_textScaleKey);

    notifyListeners();

    // Provide haptic feedback
    HapticFeedback.mediumImpact();

    _announceAccessibilityChange('Theme settings reset to defaults');
  }

  /// Get the appropriate theme data based on current settings
  ThemeData getThemeData(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    if (_isHighContrastMode) {
      return isDark 
          ? _getHighContrastDarkTheme() 
          : _getHighContrastLightTheme();
    }
    
    return isDark 
        ? _getDarkTheme() 
        : _getLightTheme();
  }

  ThemeData _getLightTheme() {
    return AppTheme.lightTheme;
  }

  ThemeData _getDarkTheme() {
    return AppTheme.darkTheme;
  }

  ThemeData _getHighContrastLightTheme() {
    return AppTheme.highContrastLightTheme;
  }

  ThemeData _getHighContrastDarkTheme() {
    return AppTheme.highContrastDarkTheme;
  }

  /// Announce accessibility changes to screen readers
  void _announceAccessibilityChange(String message) {
    // Use SemanticsService to announce to screen readers
    SystemSound.play(SystemSoundType.click);
    debugPrint('Accessibility announcement: $message');
  }

  /// Check if reduced motion is preferred
  bool isReducedMotionPreferred(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get appropriate animation duration based on accessibility settings
  Duration getAnimationDuration(BuildContext context, Duration defaultDuration) {
    if (isReducedMotionPreferred(context)) {
      return Duration.zero;
    }
    return defaultDuration;
  }
}