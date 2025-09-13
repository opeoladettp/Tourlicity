import 'package:equatable/equatable.dart';
import '../../../domain/entities/tour_template.dart';

/// States for TourTemplateBloc
abstract class TourTemplateState extends Equatable {
  const TourTemplateState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TourTemplateInitial extends TourTemplateState {
  const TourTemplateInitial();
}

/// Loading state
class TourTemplateLoading extends TourTemplateState {
  const TourTemplateLoading();
}

/// Tour templates loaded successfully
class TourTemplatesLoaded extends TourTemplateState {
  final List<TourTemplate> templates;
  final bool hasReachedMax;
  final int currentPage;
  final String? currentSearch;
  final bool? currentIsActive;
  final DateTime? currentStartDateFrom;
  final DateTime? currentStartDateTo;

  const TourTemplatesLoaded({
    required this.templates,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.currentSearch,
    this.currentIsActive,
    this.currentStartDateFrom,
    this.currentStartDateTo,
  });

  TourTemplatesLoaded copyWith({
    List<TourTemplate>? templates,
    bool? hasReachedMax,
    int? currentPage,
    String? currentSearch,
    bool? currentIsActive,
    DateTime? currentStartDateFrom,
    DateTime? currentStartDateTo,
  }) {
    return TourTemplatesLoaded(
      templates: templates ?? this.templates,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      currentSearch: currentSearch ?? this.currentSearch,
      currentIsActive: currentIsActive ?? this.currentIsActive,
      currentStartDateFrom: currentStartDateFrom ?? this.currentStartDateFrom,
      currentStartDateTo: currentStartDateTo ?? this.currentStartDateTo,
    );
  }

  @override
  List<Object?> get props => [
        templates,
        hasReachedMax,
        currentPage,
        currentSearch,
        currentIsActive,
        currentStartDateFrom,
        currentStartDateTo,
      ];
}

/// Single tour template loaded successfully
class TourTemplateLoaded extends TourTemplateState {
  final TourTemplate template;

  const TourTemplateLoaded(this.template);

  @override
  List<Object> get props => [template];
}

/// Tour template operation successful (create, update, activate, deactivate, delete)
class TourTemplateOperationSuccess extends TourTemplateState {
  final String message;
  final TourTemplate? template;

  const TourTemplateOperationSuccess({
    required this.message,
    this.template,
  });

  @override
  List<Object?> get props => [message, template];
}

/// Tour template search results
class TourTemplateSearchResults extends TourTemplateState {
  final List<TourTemplate> searchResults;
  final String query;

  const TourTemplateSearchResults({
    required this.searchResults,
    required this.query,
  });

  @override
  List<Object> get props => [searchResults, query];
}

/// Error state
class TourTemplateError extends TourTemplateState {
  final String message;
  final String? errorCode;

  const TourTemplateError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// Loading more tour templates (for pagination)
class TourTemplateLoadingMore extends TourTemplateState {
  final List<TourTemplate> currentTemplates;

  const TourTemplateLoadingMore(this.currentTemplates);

  @override
  List<Object> get props => [currentTemplates];
}
