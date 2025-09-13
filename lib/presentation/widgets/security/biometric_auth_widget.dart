import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/security/biometric_auth_service.dart';

/// Widget for biometric authentication
class BiometricAuthWidget extends StatefulWidget {
  const BiometricAuthWidget({
    super.key,
    required this.onAuthenticationSuccess,
    this.onAuthenticationFailed,
    this.title = 'Biometric Authentication',
    this.subtitle = 'Use your fingerprint or face to authenticate',
    this.localizedReason = 'Please authenticate to access your account',
    this.biometricOnly = false,
    this.showFallbackButton = true,
  });

  final VoidCallback onAuthenticationSuccess;
  final VoidCallback? onAuthenticationFailed;
  final String title;
  final String subtitle;
  final String localizedReason;
  final bool biometricOnly;
  final bool showFallbackButton;

  @override
  State<BiometricAuthWidget> createState() => _BiometricAuthWidgetState();
}

class _BiometricAuthWidgetState extends State<BiometricAuthWidget> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      final availableBiometrics = await _biometricService.getAvailableBiometrics();
      
      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable;
          _availableBiometrics = availableBiometrics;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
          _errorMessage = 'Failed to check biometric availability';
        });
      }
    }
  }

  Future<void> _authenticate() async {
    if (!_isBiometricAvailable) {
      _showErrorDialog('Biometric authentication is not available on this device');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _biometricService.authenticate(
        localizedReason: widget.localizedReason,
        biometricOnly: widget.biometricOnly,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result.isSuccess) {
          widget.onAuthenticationSuccess();
        } else {
          _handleAuthenticationError(result);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication failed: ${e.toString()}';
        });
      }
    }
  }

  void _handleAuthenticationError(BiometricAuthResult result) {
    String message;
    bool showRetry = true;

    switch (result.status) {
      case BiometricAuthStatus.cancelled:
        message = 'Authentication was cancelled';
        showRetry = true;
        break;
      case BiometricAuthStatus.notAvailable:
        message = 'Biometric authentication is not available';
        showRetry = false;
        break;
      case BiometricAuthStatus.notEnrolled:
        message = 'No biometrics are enrolled on this device';
        showRetry = false;
        break;
      case BiometricAuthStatus.lockedOut:
        message = 'Biometric authentication is temporarily locked';
        showRetry = false;
        break;
      case BiometricAuthStatus.permanentlyLockedOut:
        message = 'Biometric authentication is permanently locked';
        showRetry = false;
        break;
      case BiometricAuthStatus.biometricOnlyNotSupported:
        message = 'Biometric-only authentication is not supported';
        showRetry = true;
        break;
      case BiometricAuthStatus.error:
        message = result.errorMessage ?? 'Authentication failed';
        showRetry = true;
        break;
      default:
        message = 'Authentication failed';
        showRetry = true;
    }

    setState(() {
      _errorMessage = message;
    });

    if (!showRetry) {
      widget.onAuthenticationFailed?.call();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return Icons.visibility;
    } else {
      return Icons.security;
    }
  }

  String _getBiometricTypeText() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else {
      return 'Biometric';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (!_isBiometricAvailable) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.security_outlined,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Biometric Authentication Unavailable',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Biometric authentication is not available on this device',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getBiometricIcon(),
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _authenticate,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Icon(_getBiometricIcon()),
                label: Text(
                  _isLoading 
                      ? 'Authenticating...' 
                      : 'Authenticate with ${_getBiometricTypeText()}',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (widget.showFallbackButton) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onAuthenticationFailed,
                child: const Text('Use Password Instead'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}