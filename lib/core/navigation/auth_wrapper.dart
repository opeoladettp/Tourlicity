import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_event.dart';
import '../../presentation/blocs/auth/auth_state.dart';
import '../../presentation/widgets/common/loading_widget.dart';

/// Wrapper that ensures user is authenticated before showing child
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return state.when(
          initial: () => const LoadingWidget(message: 'Initializing...'),
          loading: () => const LoadingWidget(message: 'Loading...'),
          authenticated: (user) => child,
          unauthenticated: () =>
              const SizedBox.shrink(), // Router will handle redirect
          error: (message) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Authentication Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger auth check
                      context.read<AuthBloc>().add(const AuthCheckRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
