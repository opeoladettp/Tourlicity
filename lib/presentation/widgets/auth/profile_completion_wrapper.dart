import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../../blocs/user/user_state.dart';
import '../../pages/profile/profile_completion_page.dart';
import '../common/loading_overlay.dart';

/// Wrapper widget that checks profile completion and redirects if needed
class ProfileCompletionWrapper extends StatefulWidget {
  final Widget child;
  final User? user;

  const ProfileCompletionWrapper({
    super.key,
    required this.child,
    this.user,
  });

  @override
  State<ProfileCompletionWrapper> createState() =>
      _ProfileCompletionWrapperState();
}

class _ProfileCompletionWrapperState extends State<ProfileCompletionWrapper> {
  @override
  void initState() {
    super.initState();
    // Check profile completion when widget initializes
    if (widget.user != null) {
      _checkProfileCompletion(widget.user!);
    } else {
      // Load user profile if not provided
      context.read<UserBloc>().add(const LoadUserProfile());
    }
  }

  void _checkProfileCompletion(User user) {
    // If profile is not complete, we'll show the completion page
    // The check is done in the build method based on user data
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        // Handle any additional logic if needed
      },
      builder: (context, state) {
        // Show loading while checking user profile
        if (state is UserLoading && widget.user == null) {
          return const Scaffold(
            body: LoadingOverlay(message: 'Loading profile...'),
          );
        }

        // Get current user from state or widget
        User? currentUser = widget.user;
        if (state is UserLoaded) {
          currentUser = state.user;
        } else if (state is UserUpdated) {
          currentUser = state.user;
        } else if (state is UserProfileCompleted) {
          currentUser = state.user;
        }

        // Show error if user loading failed
        if (state is UserError && widget.user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load profile',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(const LoadUserProfile());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // If we have a user, check if profile is complete
        if (currentUser != null) {
          if (!currentUser.isProfileComplete) {
            return const ProfileCompletionPage();
          }

          // Profile is complete, show the child widget
          return widget.child;
        }

        // Fallback loading state
        return const Scaffold(
          body: LoadingOverlay(message: 'Loading...'),
        );
      },
    );
  }
}
