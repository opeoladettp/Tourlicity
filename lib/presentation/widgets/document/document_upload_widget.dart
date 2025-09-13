import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/document/document_bloc.dart';
import '../../blocs/document/document_event.dart';
import '../../blocs/document/document_state.dart';
import '../../../domain/entities/document.dart';
import '../../../core/services/file_picker_service.dart';

enum FileSelectionOption {
  document,
  image,
  camera,
  gallery,
}

class DocumentUploadWidget extends StatefulWidget {
  final String userId;
  final String? tourId;
  final DocumentType? initialType;
  final VoidCallback? onUploadSuccess;

  const DocumentUploadWidget({
    super.key,
    required this.userId,
    this.tourId,
    this.initialType,
    this.onUploadSuccess,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _filePickerService = FilePickerService();
  
  DocumentType _selectedType = DocumentType.other;
  DateTime? _expiryDate;
  String? _selectedFilePath;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    try {
      // Show file selection options
      final selectedOption = await _showFileSelectionDialog();
      if (selectedOption == null) return;

      FilePickerResult? result;
      XFile? imageFile;

      switch (selectedOption) {
        case FileSelectionOption.document:
          result = await _filePickerService.pickDocument();
          break;
        case FileSelectionOption.image:
          result = await _filePickerService.pickImage();
          break;
        case FileSelectionOption.camera:
          imageFile = await _filePickerService.pickImageFromCamera();
          break;
        case FileSelectionOption.gallery:
          imageFile = await _filePickerService.pickImageFromGallery();
          break;
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _selectedFilePath = file.path!;
            _selectedFileName = file.name;
            _selectedFileSize = file.size;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File selected: ${file.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else if (imageFile != null) {
        // Handle image from camera/gallery
        final imagePath = imageFile.path;
        final fileInfo = await _filePickerService.getFileInfo(imagePath);
        if (fileInfo != null) {
          setState(() {
            _selectedFilePath = imagePath;
            _selectedFileName = fileInfo.name;
            _selectedFileSize = fileInfo.size;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image selected: ${fileInfo.name}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } on FilePickerException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<FileSelectionOption?> _showFileSelectionDialog() async {
    return showDialog<FileSelectionOption>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select File Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.description, color: Colors.blue),
                title: const Text('Document'),
                subtitle: const Text('PDF, DOC, TXT files'),
                onTap: () => Navigator.of(context).pop(FileSelectionOption.document),
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.green),
                title: const Text('Image File'),
                subtitle: const Text('JPG, PNG, GIF files'),
                onTap: () => Navigator.of(context).pop(FileSelectionOption.image),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.orange),
                title: const Text('Take Photo'),
                subtitle: const Text('Capture with camera'),
                onTap: () => Navigator.of(context).pop(FileSelectionOption.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.purple),
                title: const Text('Photo Gallery'),
                subtitle: const Text('Select from gallery'),
                onTap: () => Navigator.of(context).pop(FileSelectionOption.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _uploadDocument() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedFilePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a file to upload'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<DocumentBloc>().add(
        UploadDocument(
          filePath: _selectedFilePath!,
          userId: widget.userId,
          tourId: widget.tourId,
          type: _selectedType,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          expiryDate: _expiryDate,
        ),
      );
    }
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );
    
    if (date != null) {
      setState(() {
        _expiryDate = date;
      });
    }
  }

  String? _validateDescription(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentBloc, DocumentState>(
      listener: (context, state) {
        if (state is DocumentUploading) {
          setState(() => _isUploading = true);
        } else {
          setState(() => _isUploading = false);
        }

        if (state is DocumentUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _resetForm();
          widget.onUploadSuccess?.call();
        }

        if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      color: Colors.blue[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Upload Document',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Document Type Selection
                DropdownButtonFormField<DocumentType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Document Type *',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: DocumentType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // File Selection
                InkWell(
                  onTap: _isUploading ? null : _selectFile,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedFilePath != null ? Colors.green : Colors.grey,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: _selectedFilePath != null 
                          ? Colors.green[50] 
                          : Colors.grey[50],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _selectedFilePath != null ? Icons.check_circle : Icons.attach_file,
                          size: 48,
                          color: _selectedFilePath != null ? Colors.green : Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFilePath != null 
                              ? 'Selected: $_selectedFileName'
                              : 'Tap to select file',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: _selectedFilePath != null ? Colors.green[700] : Colors.grey[600],
                            fontWeight: _selectedFilePath != null ? FontWeight.w600 : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_selectedFilePath != null && _selectedFileSize != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Size: ${FilePickerService.formatFileSize(_selectedFileSize!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        if (_selectedFilePath == null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Documents: PDF, DOC, TXT (Max 10MB)\nImages: JPG, PNG, GIF (Max 5MB)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Add any additional notes about this document...',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                  validator: _validateDescription,
                ),
                const SizedBox(height: 16),

                // Expiry Date (for certain document types)
                if (_requiresExpiryDate(_selectedType)) ...[
                  InkWell(
                    onTap: _isUploading ? null : _selectExpiryDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _expiryDate != null
                            ? _formatDate(_expiryDate!)
                            : 'Select expiry date',
                        style: TextStyle(
                          color: _expiryDate != null
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Upload Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadDocument,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(_isUploading ? 'Uploading...' : 'Upload Document'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Upload Progress
                if (_isUploading) ...[
                  BlocBuilder<DocumentBloc, DocumentState>(
                    builder: (context, state) {
                      if (state is DocumentUploading && state.progress != null) {
                        return Column(
                          children: [
                            LinearProgressIndicator(
                              value: state.progress! / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Uploading... ${state.progress!.toInt()}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      }
                      return const LinearProgressIndicator();
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Help Information
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Upload Guidelines',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Documents: PDF, DOC, TXT (Max 10MB)\n'
                        '• Images: JPG, PNG, GIF (Max 5MB)\n'
                        '• Take photos directly or select from gallery\n'
                        '• Documents will be reviewed by providers\n'
                        '• Keep file names descriptive and clear',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _selectedFilePath = null;
      _selectedFileName = null;
      _selectedFileSize = null;
      _expiryDate = null;
      _selectedType = widget.initialType ?? DocumentType.other;
    });
    _descriptionController.clear();
  }

  String _getTypeDisplayName(DocumentType type) {
    switch (type) {
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.visa:
        return 'Visa';
      case DocumentType.insurance:
        return 'Travel Insurance';
      case DocumentType.medicalCertificate:
        return 'Medical Certificate';
      case DocumentType.emergencyContact:
        return 'Emergency Contact';
      case DocumentType.other:
        return 'Other Document';
    }
  }

  bool _requiresExpiryDate(DocumentType type) {
    return type == DocumentType.passport ||
           type == DocumentType.visa ||
           type == DocumentType.insurance ||
           type == DocumentType.medicalCertificate;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}