import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/registration/registration_bloc.dart';
import '../../blocs/registration/registration_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import 'registration_form_page.dart';

class JoinTourPage extends StatefulWidget {
  const JoinTourPage({super.key});

  @override
  State<JoinTourPage> createState() => _JoinTourPageState();
}

class _JoinTourPageState extends State<JoinTourPage> {
  final _formKey = GlobalKey<FormState>();
  final _joinCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  void _onJoinTour() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState.isAuthenticated && authState.userEntity != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RegistrationFormPage(
              joinCode: _joinCodeController.text.trim().toUpperCase(),
              touristId: authState.userEntity!.id,
            ),
          ),
        );
      }
    }
  }

  String? _validateJoinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a join code';
    }
    
    final cleanCode = value.trim().toUpperCase();
    if (cleanCode.length < 3) {
      return 'Join code must be at least 3 characters';
    }
    
    if (cleanCode.length > 20) {
      return 'Join code must be less than 20 characters';
    }
    
    // Basic alphanumeric validation
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(cleanCode)) {
      return 'Join code can only contain letters and numbers';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Tour'),
        elevation: 0,
      ),
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
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
                const SizedBox(height: 32),
                
                // Header
                const Icon(
                  Icons.tour,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Join a Tour',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Enter the join code provided by your tour provider to register for a tour.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Join Code Input
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tour Join Code',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _joinCodeController,
                          decoration: const InputDecoration(
                            hintText: 'Enter join code (e.g., ABC123)',
                            prefixIcon: Icon(Icons.vpn_key),
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          validator: _validateJoinCode,
                          onChanged: (value) {
                            // Auto-format to uppercase
                            final upperValue = value.toUpperCase();
                            if (value != upperValue) {
                              _joinCodeController.value = _joinCodeController.value.copyWith(
                                text: upperValue,
                                selection: TextSelection.collapsed(offset: upperValue.length),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        Text(
                          'The join code is provided by your tour provider. It\'s usually a combination of letters and numbers.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Join Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onJoinTour,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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
                            'Continue to Registration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Help Section
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Need Help?',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Contact your tour provider if you don\'t have a join code\n'
                          '• Make sure you enter the code exactly as provided\n'
                          '• Join codes are case-insensitive\n'
                          '• Each tour has a unique join code',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[700],
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