import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Connection Error',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

class NotFoundErrorWidget extends StatelessWidget {
  final String? itemName;
  final VoidCallback? onRetry;

  const NotFoundErrorWidget({
    super.key,
    this.itemName,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      title: 'Not Found',
      message: '${itemName ?? 'The requested item'} could not be found.',
      icon: Icons.search_off,
      onRetry: onRetry,
    );
  }
}

class UnauthorizedErrorWidget extends StatelessWidget {
  final VoidCallback? onLogin;

  const UnauthorizedErrorWidget({
    super.key,
    this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Access Denied',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have permission to access this content.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onLogin != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onLogin,
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}