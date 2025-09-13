import '../entities/custom_tour.dart';
import '../../core/network/api_result.dart';

/// Repository interface for custom tour operations
abstract class CustomTourRepository {
  /// Get all custom tours for a provider
  Future<ApiResult<List<CustomTour>>> getCustomTours({
    String? providerId,
    TourStatus? status,
    int? page,
    int? limit,
  });

  /// Get a specific custom tour by ID
  Future<ApiResult<CustomTour>> getCustomTourById(String id);

  /// Get custom tour by join code
  Future<ApiResult<CustomTour>> getCustomTourByJoinCode(String joinCode);

  /// Create a new custom tour
  Future<ApiResult<CustomTour>> createCustomTour(CustomTour customTour);

  /// Update an existing custom tour
  Future<ApiResult<CustomTour>> updateCustomTour(CustomTour customTour);

  /// Delete a custom tour
  Future<ApiResult<void>> deleteCustomTour(String id);

  /// Update tour status
  Future<ApiResult<CustomTour>> updateTourStatus(String id, TourStatus status);

  /// Publish a tour (change status from draft to published)
  Future<ApiResult<CustomTour>> publishTour(String id);

  /// Cancel a tour
  Future<ApiResult<CustomTour>> cancelTour(String id);

  /// Start a tour (change status to active)
  Future<ApiResult<CustomTour>> startTour(String id);

  /// Complete a tour
  Future<ApiResult<CustomTour>> completeTour(String id);

  /// Update tourist count (when someone joins or leaves)
  Future<ApiResult<CustomTour>> updateTouristCount(String id, int count);

  /// Generate a new join code for a tour
  Future<ApiResult<CustomTour>> generateNewJoinCode(String id);

  /// Search tours by various criteria
  Future<ApiResult<List<CustomTour>>> searchTours({
    String? query,
    List<String>? tags,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    double? minPrice,
    double? maxPrice,
    TourStatus? status,
    int? page,
    int? limit,
  });
}