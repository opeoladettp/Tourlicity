import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../domain/entities/custom_tour.dart';
import '../../domain/repositories/custom_tour_repository.dart';
import '../models/custom_tour_model.dart';

/// Implementation of CustomTourRepository using API client
class CustomTourRepositoryImpl implements CustomTourRepository {
  final ApiClient _apiClient;

  const CustomTourRepositoryImpl(this._apiClient);

  @override
  Future<ApiResult<List<CustomTour>>> getCustomTours({
    String? providerId,
    TourStatus? status,
    int? page,
    int? limit,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (providerId != null) queryParameters['provider_id'] = providerId;
    if (status != null) queryParameters['status'] = status.name;
    if (page != null) queryParameters['page'] = page;
    if (limit != null) queryParameters['limit'] = limit;

    final result = await _apiClient.get<List<dynamic>>(
      '/custom-tours',
      queryParameters: queryParameters,
    );

    return result.fold(
      onSuccess: (data) {
        final customTours = data
            .map((json) =>
                CustomTourModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
        return ApiSuccess(data: customTours);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<CustomTour>> getCustomTourById(String id) async {
    final result =
        await _apiClient.get<Map<String, dynamic>>('/custom-tours/$id');

    return result.fold(
      onSuccess: (data) {
        final model = CustomTourModel.fromJson(data);
        return ApiSuccess(data: model.toEntity());
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<CustomTour>> getCustomTourByJoinCode(String joinCode) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      '/custom-tours/join/$joinCode',
    );

    return result.fold(
      onSuccess: (data) {
        final model = CustomTourModel.fromJson(data);
        return ApiSuccess(data: model.toEntity());
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<CustomTour>> createCustomTour(CustomTour customTour) async {
    final model = CustomTourModel.fromEntity(customTour);
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/custom-tours',
      data: model.toJson(),
    );

    return result.fold(
      onSuccess: (data) {
        final responseModel = CustomTourModel.fromJson(data);
        return ApiSuccess(data: responseModel.toEntity());
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<CustomTour>> updateCustomTour(CustomTour customTour) async {
    final model = CustomTourModel.fromEntity(customTour);
    final result = await _apiClient.put<Map<String, dynamic>>(
      '/custom-tours/${customTour.id}',
      data: model.toJson(),
    );

    return result.fold(
      onSuccess: (data) {
        final responseModel = CustomTourModel.fromJson(data);
        return ApiSuccess(data: responseModel.toEntity());
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<void>> deleteCustomTour(String id) async {
    final result = await _apiClient.delete('/custom-tours/$id');

    return result.fold(
      onSuccess: (_) => const ApiSuccess(data: null),
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<CustomTour>> updateTourStatus(
    String id,
    TourStatus status,
  ) async {
    final result = await _apiClient.patch<Map<String, dynamic>>(
      '/custom-tours/$id/status',
      data: {'status': status.name},
    );

    return result.fold(
      onSuccess: (data) {
        final model = CustomTourModel.fromJson(data);
        return ApiSuccess(data: model.toEntity());
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<CustomTour>> publishTour(String id) async {
    return updateTourStatus(id, TourStatus.published);
  }

  @override
  Future<ApiResult<CustomTour>> cancelTour(String id) async {
    return updateTourStatus(id, TourStatus.cancelled);
  }

  @override
  Future<ApiResult<CustomTour>> startTour(String id) async {
    return updateTourStatus(id, TourStatus.active);
  }

  @override
  Future<ApiResult<CustomTour>> completeTour(String id) async {
    return updateTourStatus(id, TourStatus.completed);
  }

  @override
  Future<ApiResult<CustomTour>> updateTouristCount(String id, int count) async {
    final result = await _apiClient.patch<Map<String, dynamic>>(
      '/custom-tours/$id/tourist-count',
      data: {'current_tourists': count},
    );

    return result.fold(
      onSuccess: (data) {
        final model = CustomTourModel.fromJson(data);
        return ApiSuccess(data: model.toEntity());
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<CustomTour>> generateNewJoinCode(String id) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      '/custom-tours/$id/generate-join-code',
    );

    return result.fold(
      onSuccess: (data) {
        final model = CustomTourModel.fromJson(data);
        return ApiSuccess(data: model.toEntity());
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
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
  }) async {
    final queryParameters = <String, dynamic>{};

    if (query != null) queryParameters['q'] = query;
    if (tags != null && tags.isNotEmpty) {
      queryParameters['tags'] = tags.join(',');
    }
    if (startDateFrom != null) {
      queryParameters['start_date_from'] = startDateFrom.toIso8601String();
    }
    if (startDateTo != null) {
      queryParameters['start_date_to'] = startDateTo.toIso8601String();
    }
    if (minPrice != null) queryParameters['min_price'] = minPrice;
    if (maxPrice != null) queryParameters['max_price'] = maxPrice;
    if (status != null) queryParameters['status'] = status.name;
    if (page != null) queryParameters['page'] = page;
    if (limit != null) queryParameters['limit'] = limit;

    final result = await _apiClient.get<List<dynamic>>(
      '/custom-tours/search',
      queryParameters: queryParameters,
    );

    return result.fold(
      onSuccess: (data) {
        final customTours = data
            .map((json) =>
                CustomTourModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
        return ApiSuccess(data: customTours);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }
}
