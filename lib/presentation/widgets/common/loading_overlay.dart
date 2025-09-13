import 'package:flutter/material.dart';

/// Loading overlay widget to show loading state over content
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
