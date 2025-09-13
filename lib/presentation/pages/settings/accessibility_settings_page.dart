import 'package:flutter/material.dart';
import '../../../core/theme/theme_manager.dart';
import '../../widgets/common/accessibility_widgets.dart';
import '../../widgets/common/responsive_layout.dart';

/// Page for managing accessibility settings
class AccessibilitySettingsPage extends StatefulWidget {
  final ThemeManager themeManager;

  const AccessibilitySettingsPage({
    super.key,
    required this.themeManager,
  });

  @override
  State<AccessibilitySettingsPage> createState() => _AccessibilitySettingsPageState();
}

class _AccessibilitySettingsPageState extends State<AccessibilitySettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
        leading: AccessibleIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
          semanticLabel: 'Go back to previous page',
          tooltip: 'Back',
        ),
      ),
      body: ResponsiveContainer(
        child: ListView(
          children: [
            // Theme Settings Section
            _buildSectionHeader('Theme Settings'),
            ResponsiveCard(
              child: Column(
                children: [
                  _buildThemeModeSelector(),
                  const Divider(),
                  _buildHighContrastToggle(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Text Settings Section
            _buildSectionHeader('Text Settings'),
            ResponsiveCard(
              child: Column(
                children: [
                  _buildTextScaleSlider(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Motion Settings Section
            _buildSectionHeader('Motion Settings'),
            ResponsiveCard(
              child: Column(
                children: [
                  _buildReduceMotionInfo(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Reset Section
            _buildSectionHeader('Reset Settings'),
            ResponsiveCard(
              child: _buildResetButton(),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Theme mode selection',
          child: Text(
            'Theme Mode',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          label: 'Theme mode options',
          child: Wrap(
            spacing: 8,
            children: [
              _buildThemeChip(
                label: 'System',
                value: ThemeMode.system,
                icon: Icons.brightness_auto,
              ),
              _buildThemeChip(
                label: 'Light',
                value: ThemeMode.light,
                icon: Icons.brightness_high,
              ),
              _buildThemeChip(
                label: 'Dark',
                value: ThemeMode.dark,
                icon: Icons.brightness_low,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeChip({
    required String label,
    required ThemeMode value,
    required IconData icon,
  }) {
    final isSelected = widget.themeManager.themeMode == value;
    
    return Semantics(
      label: '$label theme mode',
      selected: isSelected,
      button: true,
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            widget.themeManager.setThemeMode(value);
          }
        },
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildHighContrastToggle() {
    return AccessibleListTile(
      leading: const Icon(Icons.contrast),
      title: const Text('High Contrast Mode'),
      subtitle: const Text('Increases contrast for better visibility'),
      trailing: Semantics(
        label: widget.themeManager.isHighContrastMode 
            ? 'High contrast mode enabled' 
            : 'High contrast mode disabled',
        child: Switch(
          value: widget.themeManager.isHighContrastMode,
          onChanged: (value) {
            widget.themeManager.setHighContrastMode(value);
          },
        ),
      ),
      onTap: () {
        widget.themeManager.toggleHighContrastMode();
      },
      semanticLabel: 'Toggle high contrast mode',
    );
  }

  Widget _buildTextScaleSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text Size',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Adjust text size for better readability',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Semantics(
          label: 'Text size slider, current value ${(widget.themeManager.textScaleFactor * 100).round()}%',
          child: Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: widget.themeManager.textScaleFactor,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  label: '${(widget.themeManager.textScaleFactor * 100).round()}%',
                  onChanged: (value) {
                    widget.themeManager.setTextScaleFactor(value);
                  },
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        Center(
          child: Text(
            'Sample text at ${(widget.themeManager.textScaleFactor * 100).round()}% size',
            style: TextStyle(
              fontSize: 16 * widget.themeManager.textScaleFactor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReduceMotionInfo() {
    final isReducedMotion = MediaQuery.of(context).disableAnimations;
    
    return AccessibleListTile(
      leading: Icon(
        isReducedMotion ? Icons.motion_photos_off : Icons.motion_photos_on,
      ),
      title: const Text('Reduce Motion'),
      subtitle: Text(
        isReducedMotion 
            ? 'Motion is reduced based on system settings'
            : 'Motion animations are enabled',
      ),
      trailing: Icon(
        isReducedMotion ? Icons.check_circle : Icons.info_outline,
        color: isReducedMotion ? Colors.green : null,
      ),
      semanticLabel: isReducedMotion 
          ? 'Reduced motion is enabled' 
          : 'Reduced motion is disabled',
    );
  }

  Widget _buildResetButton() {
    return AccessibleButton(
      onPressed: () => _showResetDialog(),
      semanticLabel: 'Reset all accessibility settings to defaults',
      type: ButtonType.outlined,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restore),
          SizedBox(width: 8),
          Text('Reset to Defaults'),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => Semantics(
        label: 'Reset settings confirmation dialog',
        child: AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text(
            'This will reset all accessibility settings to their default values. Are you sure?',
          ),
          actions: [
            AccessibleButton(
              onPressed: () => Navigator.of(context).pop(),
              semanticLabel: 'Cancel reset',
              type: ButtonType.text,
              child: const Text('Cancel'),
            ),
            AccessibleButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.themeManager.resetToDefaults();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to defaults'),
                  ),
                );
              },
              semanticLabel: 'Confirm reset settings',
              type: ButtonType.text,
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}