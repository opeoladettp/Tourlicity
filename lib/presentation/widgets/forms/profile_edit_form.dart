import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_type.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';

/// Form widget for editing user profile
class ProfileEditForm extends StatefulWidget {
  final User user;

  const ProfileEditForm({
    super.key,
    required this.user,
  });

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field (Read-only)
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.lock_outline),
            ),
            readOnly: true,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

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

          // Phone Field
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
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
          const SizedBox(height: 16),

          // User Type Display (Read-only)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  _getUserTypeIcon(widget.user.userType),
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Type',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      _getUserTypeDisplayName(widget.user.userType),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

          // Save Changes Button
          ElevatedButton(
            onPressed: _onSaveChanges,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _onSaveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phone = _phoneController.text.trim();

      // Check if any changes were made
      final hasChanges = firstName != widget.user.firstName ||
          lastName != widget.user.lastName ||
          phone != (widget.user.phone ?? '');

      if (!hasChanges) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No changes to save'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      context.read<UserBloc>().add(
            UpdateUserProfile(
              firstName: firstName,
              lastName: lastName,
              phone: phone.isNotEmpty ? phone : null,
            ),
          );
    }
  }

  IconData _getUserTypeIcon(UserType userType) {
    switch (userType) {
      case UserType.systemAdmin:
        return Icons.admin_panel_settings;
      case UserType.providerAdmin:
        return Icons.business;
      case UserType.tourist:
        return Icons.person;
    }
  }

  String _getUserTypeDisplayName(UserType userType) {
    switch (userType) {
      case UserType.systemAdmin:
        return 'System Administrator';
      case UserType.providerAdmin:
        return 'Provider Administrator';
      case UserType.tourist:
        return 'Tourist';
    }
  }
}
