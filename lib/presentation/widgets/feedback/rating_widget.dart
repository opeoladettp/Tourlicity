import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

/// Reusable rating widget for collecting user ratings
class RatingWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final double initialRating;
  final double minRating;
  final double maxRating;
  final bool allowHalfRating;
  final bool showLabels;
  final Function(double rating) onRatingChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double itemSize;
  final bool isReadOnly;

  const RatingWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.initialRating = 0.0,
    this.minRating = 1.0,
    this.maxRating = 5.0,
    this.allowHalfRating = false,
    this.showLabels = true,
    required this.onRatingChanged,
    this.activeColor,
    this.inactiveColor,
    this.itemSize = 40.0,
    this.isReadOnly = false,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  String _getRatingLabel(double rating) {
    if (rating <= 1) return 'Poor';
    if (rating <= 2) return 'Fair';
    if (rating <= 3) return 'Good';
    if (rating <= 4) return 'Very Good';
    return 'Excellent';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  RatingBar.builder(
                    initialRating: _currentRating,
                    minRating: widget.minRating,
                    direction: Axis.horizontal,
                    allowHalfRating: widget.allowHalfRating,
                    itemCount: widget.maxRating.toInt(),
                    itemSize: widget.itemSize,
                    ignoreGestures: widget.isReadOnly,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: widget.activeColor ?? theme.colorScheme.primary,
                    ),
                    unratedColor: widget.inactiveColor ?? theme.colorScheme.outline,
                    onRatingUpdate: (rating) {
                      setState(() {
                        _currentRating = rating;
                      });
                      widget.onRatingChanged(rating);
                    },
                  ),
                  if (widget.showLabels && _currentRating > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      _getRatingLabel(_currentRating),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple star rating display widget (read-only)
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final double maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showRatingText;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.maxRating = 5.0,
    this.size = 20.0,
    this.activeColor,
    this.inactiveColor,
    this.showRatingText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => Icon(
            Icons.star,
            color: activeColor ?? theme.colorScheme.primary,
          ),
          itemCount: maxRating.toInt(),
          itemSize: size,
          unratedColor: inactiveColor ?? theme.colorScheme.outline,
        ),
        if (showRatingText) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}