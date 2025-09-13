import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/security/biometric_auth_service.dart';
import '../../../core/security/secure_session_manager.dart';
// import '../../widgets/security/biometric_auth_widget.dart'; // Temporarily disabled

/// Security settings page for configuring security options
class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({
    super.key,
    required this.sessionManager,
  });

  final SecureSessionManager sessionManager;

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  
  bool _biometricEnabled = false;
  bool _isBiometricAvailable = false;
  bool _autoLockEnabled = true;
  int _autoLockMinutes = 15;
  bool _requireBiometricForSensitive = false;
  bool _isLoading = true;
  
  SessionInfo? _sessionInfo;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSessionInfo();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isBiometricAvailable = await _biometricService.isBiometricAvailable();
      
      if (mounted) {
        setState(() {
          _isBiometricAvailable = isBiometricAvailable;
          _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
          _autoLockEnabled = prefs.getBool('auto_lock_enabled') ?? true;
          _autoLockMinutes = prefs.getInt('auto_lock_minutes') ?? 15;
          _requireBiometricForSensitive = prefs.getBool('require_biometric_sensitive') ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load security settings');
      }
    }
  }

  Future<void> _loadSessionInfo() async {
    try {
      final sessionInfo = await widget.sessionManager.getSessionInfo();
      if (mounted) {
        setState(() {
          _sessionInfo = sessionInfo;
        });
      }
    } catch (e) {
      // Session info is optional, don't show error
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save setting');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (enabled && _isBiometricAvailable) {
      // Test biometric authentication before enabling
      final result = await _biometricService.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
      );
      
      if (result.isSuccess) {
        setState(() {
          _biometricEnabled = true;
        });
        await _saveSetting('biometric_enabled', true);
        _showSuccessSnackBar('Biometric authentication enabled');
      } else {
        _showErrorSnackBar('Biometric authentication failed');
      }
    } else {
      setState(() {
        _biometricEnabled = false;
        _requireBiometricForSensitive = false;
      });
      await _saveSetting('biometric_enabled', false);
      await _saveSetting('require_biometric_sensitive', false);
      _showSuccessSnackBar('Biometric authentication disabled');
    }
  }

  Future<void> _clearAllSessions() async {
    final confirmed = await _showConfirmationDialog(
      'Clear All Sessions',
      'This will sign you out from all devices. Are you sure?',
    );
    
    if (confirmed) {
      try {
        await widget.sessionManager.clearSession();
        _showSuccessSnackBar('All sessions cleared');
        // Navigate back to login
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        _showErrorSnackBar('Failed to clear sessions');
      }
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildSessionInfoCard() {
    if (_sessionInfo == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final sessionDuration = _sessionInfo!.sessionDuration;
    final timeSinceActivity = _sessionInfo!.timeSinceLastActivity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Session',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Session ID', '${_sessionInfo!.sessionId.substring(0, 8)}...'),
            if (sessionDuration != null)
              _buildInfoRow('Session Duration', _formatDuration(sessionDuration)),
            if (timeSinceActivity != null)
              _buildInfoRow('Last Activity', '${_formatDuration(timeSinceActivity)} ago'),
            _buildInfoRow('Device Fingerprint', '${_sessionInfo!.deviceFingerprint.substring(0, 8)}...'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Security Settings'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Biometric Authentication Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.fingerprint,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Biometric Authentication',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Enable Biometric Login'),
                    subtitle: Text(
                      _isBiometricAvailable
                          ? 'Use fingerprint or face recognition to sign in'
                          : 'Biometric authentication is not available',
                    ),
                    value: _biometricEnabled && _isBiometricAvailable,
                    onChanged: _isBiometricAvailable ? _toggleBiometric : null,
                  ),
                  if (_biometricEnabled && _isBiometricAvailable)
                    SwitchListTile(
                      title: const Text('Require for Sensitive Actions'),
                      subtitle: const Text('Require biometric authentication for sensitive operations'),
                      value: _requireBiometricForSensitive,
                      onChanged: (value) async {
                        setState(() {
                          _requireBiometricForSensitive = value;
                        });
                        await _saveSetting('require_biometric_sensitive', value);
                      },
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Auto-Lock Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lock_clock,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Auto-Lock',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Enable Auto-Lock'),
                    subtitle: const Text('Automatically lock the app after inactivity'),
                    value: _autoLockEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _autoLockEnabled = value;
                      });
                      await _saveSetting('auto_lock_enabled', value);
                    },
                  ),
                  if (_autoLockEnabled)
                    ListTile(
                      title: const Text('Auto-Lock Time'),
                      subtitle: Text('Lock after $_autoLockMinutes minutes of inactivity'),
                      trailing: DropdownButton<int>(
                        value: _autoLockMinutes,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 minute')),
                          DropdownMenuItem(value: 5, child: Text('5 minutes')),
                          DropdownMenuItem(value: 15, child: Text('15 minutes')),
                          DropdownMenuItem(value: 30, child: Text('30 minutes')),
                          DropdownMenuItem(value: 60, child: Text('1 hour')),
                        ],
                        onChanged: (value) async {
                          if (value != null) {
                            setState(() {
                              _autoLockMinutes = value;
                            });
                            await _saveSetting('auto_lock_minutes', value);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Session Information
          _buildSessionInfoCard(),
          
          const SizedBox(height: 16),
          
          // Security Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Security Actions',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: theme.colorScheme.error,
                    ),
                    title: const Text('Sign Out All Devices'),
                    subtitle: const Text('Clear all active sessions'),
                    onTap: _clearAllSessions,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}