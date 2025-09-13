import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../widgets/auth/google_sign_in_button.dart';

/// Login page with Google Sign-in
class LoginPage extends StatelessWidget {
  final String? errorMessage;

  const LoginPage({
    super.key,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo and Title
              Icon(
                Icons.tour,
                size: 120,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Tourlicity',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Tour Management Platform',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 48),

              // Error message if any
              if (errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Sign in section
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),

              // Google Sign-in Button
              GoogleSignInButton(
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(const AuthGoogleSignInRequested());
                },
              ),

              // Development info (only in debug mode)
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                Text(
                  'Development mode: Connected to backend at\nhttp://localhost:3000/api/v1/auth/google',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green[600],
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],

              const SizedBox(height: 32),

              // Terms and Privacy
              Text(
                'By signing in, you agree to our Terms of Service and Privacy Policy',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
