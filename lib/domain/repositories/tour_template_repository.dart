import '../entities/tour_template.dart';
import '../../core/network/api_result.dart';

/// Repository interface for tour template management operations
abstract class TourTemplateRepository {
  /// Get all tour templates with optional filtering
  Future<ApiResult<List<TourTemplate>>> getTourTemplates({
    String? search,
    bool? isActive,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    int? page,
    int? limit,
  });

  /// Get a specific tour template by ID
  Future<ApiResult<TourTemplate>> getTourTemplateById(String id);

  /// Create a new tour template
  Future<ApiResult<TourTemplate>> createTourTemplate(TourTemplate template);

  /// Update an existing tour template
  Future<ApiResult<TourTemplate>> updateTourTemplate(
      String id, TourTemplate template);

  /// Activate a tour template
  Future<ApiResult<TourTemplate>> activateTourTemplate(String id);

  /// Deactivate a tour template
  Future<ApiResult<TourTemplate>> deactivateTourTemplate(String id);

  /// Delete a tour template (soft delete)
  Future<ApiResult<void>> deleteTourTemplate(String id);

  /// Search tour templates by name
  Future<ApiResult<List<TourTemplate>>> searchTourTemplates(String query);
}
