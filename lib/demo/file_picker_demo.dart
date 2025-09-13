import 'package:flutter/material.dart';
import '../core/services/file_picker_service.dart';

/// Demo page to test file picker functionality
class FilePickerDemo extends StatefulWidget {
  const FilePickerDemo({super.key});

  @override
  State<FilePickerDemo> createState() => _FilePickerDemoState();
}

class _FilePickerDemoState extends State<FilePickerDemo> {
  final _filePickerService = FilePickerService();
  String? _selectedFilePath;
  String? _selectedFileName;
  int? _selectedFileSize;
  String? _errorMessage;

  Future<void> _pickDocument() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final result = await _filePickerService.pickDocument();
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFilePath = file.path;
          _selectedFileName = file.name;
          _selectedFileSize = file.size;
        });
      }
    } on FilePickerException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final result = await _filePickerService.pickImage();
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFilePath = file.path;
          _selectedFileName = file.name;
          _selectedFileSize = file.size;
        });
      }
    } on FilePickerException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final image = await _filePickerService.pickImageFromCamera();
      if (image != null) {
        final fileInfo = await _filePickerService.getFileInfo(image.path);
        if (fileInfo != null) {
          setState(() {
            _selectedFilePath = image.path;
            _selectedFileName = fileInfo.name;
            _selectedFileSize = fileInfo.size;
          });
        }
      }
    } on FilePickerException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final image = await _filePickerService.pickImageFromGallery();
      if (image != null) {
        final fileInfo = await _filePickerService.getFileInfo(image.path);
        if (fileInfo != null) {
          setState(() {
            _selectedFilePath = image.path;
            _selectedFileName = fileInfo.name;
            _selectedFileSize = fileInfo.size;
          });
        }
      }
    } on FilePickerException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFilePath = null;
      _selectedFileName = null;
      _selectedFileSize = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Picker Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // File Selection Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Select File',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons.description),
                      label: const Text('Pick Document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pick Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Pick from Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selected File Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selected File',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_selectedFilePath != null)
                          TextButton.icon(
                            onPressed: _clearSelection,
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_selectedFilePath != null) ...[
                      _buildInfoRow('File Name:', _selectedFileName ?? 'Unknown'),
                      _buildInfoRow('File Path:', _selectedFilePath ?? 'Unknown'),
                      if (_selectedFileSize != null)
                        _buildInfoRow(
                          'File Size:',
                          FilePickerService.formatFileSize(_selectedFileSize!),
                        ),
                    ] else ...[
                      const Text(
                        'No file selected',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Error Message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Error',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            // File Type Information
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Supported File Types',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Documents: ${FilePickerService.allowedDocumentExtensions.join(', ').toUpperCase()} (Max 10MB)\n'
                      'Images: ${FilePickerService.allowedImageExtensions.join(', ').toUpperCase()} (Max 5MB)',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}