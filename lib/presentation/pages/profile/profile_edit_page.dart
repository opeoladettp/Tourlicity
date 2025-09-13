import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_state.dart';
import '../../widgets/forms/profile_edit_form.dart';
import '../../widgets/common/loading_overlay.dart';

/// Page for editing user profile
class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoaded) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ProfileEditForm(user: state.user),
                ),
                if (state is UserUpdating)
                  const LoadingOverlay(message: 'Updating profile...'),
              ],
            );
          }

          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No user data available'));
        },
      ),
    );
  }
}
