import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/entities.dart';
import '../../blocs/provider/provider_bloc.dart';
import '../../blocs/provider/provider_event.dart';
import '../../blocs/provider/provider_state.dart';

/// Page for creating or editing a provider
class ProviderFormPage extends StatefulWidget {
  const ProviderFormPage({
    super.key,
    this.provider,
  });

  final Provider? provider;

  @override
  State<ProviderFormPage> createState() => _ProviderFormPageState();
}

class _ProviderFormPageState extends State<ProviderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get _isEditing => widget.provider != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateForm();
    }
  }

  void _populateForm() {
    final provider = widget.provider!;
    _nameController.text = provider.name;
    _emailController.text = provider.email;
    _phoneController.text = provider.phoneNumber;
    _addressController.text = provider.address ?? '';
    _descriptionController.text = provider.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Provider' : 'Add Provider'),
        actions: [
          TextButton(
            onPressed: _saveProvider,
            child: const Text('Save'),
          ),
        ],
      ),
      body: BlocListener<ProviderBloc, ProviderState>(
        listener: (context, state) {
          if (state is ProviderOperationSuccess) {
            Navigator.of(context).pop();
          } else if (state is ProviderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Provider Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter provider name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveProvider() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider(
        id: _isEditing ? widget.provider!.id : '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (_isEditing) {
        context
            .read<ProviderBloc>()
            .add(UpdateProvider(widget.provider!.id, provider));
      } else {
        context.read<ProviderBloc>().add(CreateProvider(provider));
      }
    }
  }
}
