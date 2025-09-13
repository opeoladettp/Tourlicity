import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/registration/registration_bloc.dart';
import '../../blocs/registration/registration_event.dart';
import '../../blocs/registration/registration_state.dart';

class RegistrationFormPage extends StatefulWidget {
  final String joinCode;
  final String touristId;

  const RegistrationFormPage({
    super.key,
    required this.joinCode,
    required this.touristId,
  });

  @override
  State<RegistrationFormPage> createState() => _RegistrationFormPageState();
}

class _RegistrationFormPageState extends State<RegistrationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _specialRequirementsController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasEmergencyContact = false;

  @override
  void dispose() {
    _specialRequirementsController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  void _onSubmitRegistration() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RegistrationBloc>().add(
        RegisterForTour(
          joinCode: widget.joinCode,
          touristId: widget.touristId,
          specialRequirements: _specialRequirementsController.text.trim().isEmpty
              ? null
              : _specialRequirementsController.text.trim(),
          emergencyContactName: _hasEmergencyContact && _emergencyContactNameController.text.trim().isNotEmpty
              ? _emergencyContactNameController.text.trim()
              : null,
          emergencyContactPhone: _hasEmergencyContact && _emergencyContactPhoneController.text.trim().isNotEmpty
              ? _emergencyContactPhoneController.text.trim()
              : null,
        ),
      );
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (!_hasEmergencyContact || value == null || value.trim().isEmpty) {
      return null;
    }
    
    final phone = value.trim();
    // Basic phone validation - adjust regex based on your requirements
    if (!RegExp(r'^\+?[\d\s\-\(\)\.]{10,}$').hasMatch(phone)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  String? _validateEmergencyContactName(String? value) {
    if (!_hasEmergencyContact) return null;
    
    if (_emergencyContactPhoneController.text.trim().isNotEmpty) {
      if (value == null || value.trim().isEmpty) {
        return 'Emergency contact name is required when phone is provided';
      }
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Form'),
        elevation: 0,
      ),
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is RegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }

          if (state is RegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 48,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tour Registration',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join Code: ${widget.joinCode}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Special Requirements Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Special Requirements',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please let us know if you have any special requirements or accessibility needs.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _specialRequirementsController,
                          decoration: const InputDecoration(
                            hintText: 'e.g., Wheelchair accessible, Dietary restrictions, etc.',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          maxLength: 500,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Emergency Contact Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Emergency Contact',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Switch(
                              value: _hasEmergencyContact,
                              onChanged: (value) {
                                setState(() {
                                  _hasEmergencyContact = value;
                                  if (!value) {
                                    _emergencyContactNameController.clear();
                                    _emergencyContactPhoneController.clear();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Provide an emergency contact person who can be reached during the tour.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        if (_hasEmergencyContact) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emergencyContactNameController,
                            decoration: const InputDecoration(
                              labelText: 'Contact Name',
                              hintText: 'Full name of emergency contact',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: _validateEmergencyContactName,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emergencyContactPhoneController,
                            decoration: const InputDecoration(
                              labelText: 'Contact Phone',
                              hintText: '+1 (555) 123-4567',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: _validatePhoneNumber,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSubmitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit Registration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Terms and Conditions
                Card(
                  color: Colors.grey[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Important Information',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Your registration will be reviewed by the tour provider\n'
                          '• You will receive a confirmation once approved\n'
                          '• Special requirements will be accommodated when possible\n'
                          '• Emergency contact information is kept confidential',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}