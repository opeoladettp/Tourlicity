import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_state.dart';
import '../../widgets/forms/profile_completion_form.dart';
import '../../widgets/common/loading_overlay.dart';

/// Page for completing user profile after initial registration
class ProfileCompletionPage extends StatelessWidget {
  const ProfileCompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return Stack(
            children: [
              const SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Tourlicity!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please complete your profile to get started.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 32),
                    ProfileCompletionForm(),
                  ],
                ),
              ),
              if (state is UserLoading || state is UserProfileCompleting)
                const LoadingOverlay(message: 'Completing profile...'),
            ],
          );
        },
      ),
    );
  }
}
