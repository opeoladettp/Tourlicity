import 'package:flutter/material.dart';
import '../../../core/feedback/feedback_service.dart';
import '../../../core/logging/error_logger.dart';
import 'rating_widget.dart';

/// Comprehensive feedback form widget
class FeedbackFormWidget extends StatefulWidget {
  final String title;
  final FeedbackType feedbackType;
  final String? entityId; // Tour ID, Provider ID, etc.
  final String? entityName;
  final String? userId;
  final String? userType;
  final VoidCallback? onSubmitted;

  const FeedbackFormWidget({
    super.key,
    required this.title,
    required this.feedbackType,
    this.entityId,
    this.entityName,
    this.userId,
    this.userType,
    this.onSubmitted,
  });

  @override
  State<FeedbackFormWidget> createState() => _FeedbackFormWidgetState();
}

class _FeedbackFormWidgetState extends State<FeedbackFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();
  final _expectedController = TextEditingController();
  final _actualController = TextEditingController();
  final _justificationController = TextEditingController();
  
  double _rating = 0.0;
  String _selectedCategory = '';
  int _priority = 1;
  bool _isSubmitting = false;

  final List<String> _generalCategories = [
    'User Interface',
    'Performance',
    'Features',
    'Bug Report',
    'Suggestion',
    'Other',
  ];

  final List<String> _tourCategories = [
    'Tour Content',
    'Tour Guide',
    'Organization',
    'Value for Money',
    'Overall Experience',
  ];

  final List<String> _providerCategories = [
    'Communication',
    'Professionalism',
    'Tour Quality',
    'Customer Service',
    'Overall Experience',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _getCategories().first;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    _expectedController.dispose();
    _actualController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  List<String> _getCategories() {
    switch (widget.feedbackType) {
      case FeedbackType.tour:
        return _tourCategories;
      case FeedbackType.provider:
        return _providerCategories;
      case FeedbackType.general:
      case FeedbackType.bug:
      case FeedbackType.feature:
        return _generalCategories;
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final feedbackService = FeedbackService.instance;
      
      switch (widget.feedbackType) {
        case FeedbackType.tour:
          await feedbackService.submitTourRating(
            tourId: widget.entityId!,
            tourName: widget.entityName!,
            rating: _rating,
            comment: _commentController.text.trim(),
            userId: widget.userId,
            categories: [_selectedCategory],
          );
          break;
          
        case FeedbackType.provider:
          await feedbackService.submitProviderRating(
            providerId: widget.entityId!,
            providerName: widget.entityName!,
            rating: _rating,
            comment: _commentController.text.trim(),
            userId: widget.userId,
            categories: [_selectedCategory],
          );
          break;
          
        case FeedbackType.general:
          await feedbackService.submitGeneralFeedback(
            category: _selectedCategory,
            message: _commentController.text.trim(),
            userId: widget.userId,
            userType: widget.userType,
          );
          break;
          
        case FeedbackType.bug:
          await feedbackService.submitBugReport(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            stepsToReproduce: _stepsController.text.trim(),
            expectedBehavior: _expectedController.text.trim(),
            actualBehavior: _actualController.text.trim(),
            userId: widget.userId,
            userType: widget.userType,
          );
          break;
          
        case FeedbackType.feature:
          await feedbackService.submitFeatureRequest(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            justification: _justificationController.text.trim(),
            userId: widget.userId,
            userType: widget.userType,
            priority: _priority,
          );
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
        
        widget.onSubmitted?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      await ErrorLogger.instance.logError(
        message: 'Failed to submit feedback',
        exception: e,
        category: 'feedback_submission_error',
        additionalData: {
          'feedback_type': widget.feedbackType.name,
          'entity_id': widget.entityId,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit feedback. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.feedbackType == FeedbackType.tour ||
                  widget.feedbackType == FeedbackType.provider) ...[
                RatingWidget(
                  title: 'Rate ${widget.feedbackType == FeedbackType.tour ? 'Tour' : 'Provider'}',
                  subtitle: widget.entityName,
                  onRatingChanged: (rating) {
                    _rating = rating;
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              if (widget.feedbackType == FeedbackType.bug ||
                  widget.feedbackType == FeedbackType.feature) ...[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: widget.feedbackType == FeedbackType.bug 
                        ? 'Bug Title' 
                        : 'Feature Title',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _getCategories().map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              if (widget.feedbackType == FeedbackType.bug) ...[
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Bug Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe the bug';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _stepsController,
                  decoration: const InputDecoration(
                    labelText: 'Steps to Reproduce',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide steps to reproduce';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _expectedController,
                  decoration: const InputDecoration(
                    labelText: 'Expected Behavior',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _actualController,
                  decoration: const InputDecoration(
                    labelText: 'Actual Behavior',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
              ],

              if (widget.feedbackType == FeedbackType.feature) ...[
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Feature Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe the feature';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _justificationController,
                  decoration: const InputDecoration(
                    labelText: 'Why is this feature needed?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please provide justification';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<int>(
                  initialValue: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Low')),
                    DropdownMenuItem(value: 2, child: Text('Medium')),
                    DropdownMenuItem(value: 3, child: Text('High')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _priority = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: widget.feedbackType == FeedbackType.general 
                      ? 'Message' 
                      : 'Additional Comments',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (widget.feedbackType == FeedbackType.general &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum FeedbackType {
  tour,
  provider,
  general,
  bug,
  feature,
}