import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';

/// Form widget for completing user profile
class ProfileCompletionForm extends StatefulWidget {
  const ProfileCompletionForm({super.key});

  @override
  State<ProfileCompletionForm> createState() => _ProfileCompletionFormState();
}

class _ProfileCompletionFormState extends State<ProfileCompletionForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First Name Field
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name *',
              hintText: 'Enter your first name',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'First name is required';
              }
              if (value.trim().length < 2) {
                return 'First name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Last Name Field
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name *',
              hintText: 'Enter your last name',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Last name is required';
              }
              if (value.trim().length < 2) {
                return 'Last name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Field (Optional)
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number (optional)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                // Basic phone validation if provided
                final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
                if (!phoneRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid phone number';
                }
                if (value.trim().length < 10) {
                  return 'Phone number must be at least 10 digits';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Required fields note
          const Text(
            '* Required fields',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Complete Profile Button
          ElevatedButton(
            onPressed: _onCompleteProfile,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Complete Profile',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _onCompleteProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phone = _phoneController.text.trim();

      context.read<UserBloc>().add(
            CompleteUserProfile(
              firstName: firstName,
              lastName: lastName,
              phone: phone.isNotEmpty ? phone : null,
            ),
          );
    }
  }
}
