import 'package:equatable/equatable.dart';
import '../../../domain/entities/tour_template.dart';

/// Events for TourTemplateBloc
abstract class TourTemplateEvent extends Equatable {
  const TourTemplateEvent();

  @override
  List<Object?> get props => [];
}

/// Load tour templates with optional filters
class LoadTourTemplates extends TourTemplateEvent {
  final String? search;
  final bool? isActive;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;
  final int? page;
  final int? limit;

  const LoadTourTemplates({
    this.search,
    this.isActive,
    this.startDateFrom,
    this.startDateTo,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props =>
      [search, isActive, startDateFrom, startDateTo, page, limit];
}

/// Load a specific tour template by ID
class LoadTourTemplateById extends TourTemplateEvent {
  final String id;

  const LoadTourTemplateById(this.id);

  @override
  List<Object> get props => [id];
}

/// Create a new tour template
class CreateTourTemplate extends TourTemplateEvent {
  final TourTemplate template;

  const CreateTourTemplate(this.template);

  @override
  List<Object> get props => [template];
}

/// Update an existing tour template
class UpdateTourTemplate extends TourTemplateEvent {
  final String id;
  final TourTemplate template;

  const UpdateTourTemplate(this.id, this.template);

  @override
  List<Object> get props => [id, template];
}

/// Activate a tour template
class ActivateTourTemplate extends TourTemplateEvent {
  final String id;

  const ActivateTourTemplate(this.id);

  @override
  List<Object> get props => [id];
}

/// Deactivate a tour template
class DeactivateTourTemplate extends TourTemplateEvent {
  final String id;

  const DeactivateTourTemplate(this.id);

  @override
  List<Object> get props => [id];
}

/// Delete a tour template
class DeleteTourTemplate extends TourTemplateEvent {
  final String id;

  const DeleteTourTemplate(this.id);

  @override
  List<Object> get props => [id];
}

/// Search tour templates by query
class SearchTourTemplates extends TourTemplateEvent {
  final String query;

  const SearchTourTemplates(this.query);

  @override
  List<Object> get props => [query];
}

/// Clear tour template search results
class ClearTourTemplateSearch extends TourTemplateEvent {
  const ClearTourTemplateSearch();
}

/// Refresh tour templates list
class RefreshTourTemplates extends TourTemplateEvent {
  const RefreshTourTemplates();
}
