import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../domain/entities/tour_template.dart';
import '../../domain/repositories/tour_template_repository.dart';
import '../models/tour_template_model.dart';

/// Implementation of TourTemplateRepository using API client
class TourTemplateRepositoryImpl implements TourTemplateRepository {
  final ApiClient _apiClient;

  const TourTemplateRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<ApiResult<List<TourTemplate>>> getTourTemplates({
    String? search,
    bool? isActive,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    int? page,
    int? limit,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    if (isActive != null) {
      queryParameters['is_active'] = isActive;
    }
    if (startDateFrom != null) {
      queryParameters['start_date_from'] = startDateFrom.toIso8601String();
    }
    if (startDateTo != null) {
      queryParameters['start_date_to'] = startDateTo.toIso8601String();
    }
    if (page != null) {
      queryParameters['page'] = page;
    }
    if (limit != null) {
      queryParameters['limit'] = limit;
    }

    final result = await _apiClient.get<List<dynamic>>(
      '/tour-templates',
      queryParameters: queryParameters,
    );

    return result.fold(
      onSuccess: (data) {
        final templates = data
            .map((json) =>
                TourTemplateModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
        return ApiSuccess(data: templates);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<TourTemplate>> getTourTemplateById(String id) async {
    final result =
        await _apiClient.get<Map<String, dynamic>>('/tour-templates/$id');

    return result.fold(
      onSuccess: (data) {
        final template = TourTemplateModel.fromJson(data).toEntity();
        return ApiSuccess(data: template);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<TourTemplate>> createTourTemplate(
      TourTemplate template) async {
    final templateModel = TourTemplateModel.fromEntity(template);
    final requestData = templateModel.toJson();

    // Remove id and created_date for creation
    requestData.remove('id');
    requestData.remove('created_date');

    final result = await _apiClient.post<Map<String, dynamic>>(
      '/tour-templates',
      data: requestData,
    );

    return result.fold(
      onSuccess: (data) {
        final template = TourTemplateModel.fromJson(data).toEntity();
        return ApiSuccess(data: template);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<TourTemplate>> updateTourTemplate(
      String id, TourTemplate template) async {
    final templateModel = TourTemplateModel.fromEntity(template);
    final requestData = templateModel.toJson();

    // Remove fields that shouldn't be updated
    requestData.remove('id');
    requestData.remove('created_date');

    final result = await _apiClient.put<Map<String, dynamic>>(
      '/tour-templates/$id',
      data: requestData,
    );

    return result.fold(
      onSuccess: (data) {
        final template = TourTemplateModel.fromJson(data).toEntity();
        return ApiSuccess(data: template);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<TourTemplate>> activateTourTemplate(String id) async {
    final result = await _apiClient
        .patch<Map<String, dynamic>>('/tour-templates/$id/activate');

    return result.fold(
      onSuccess: (data) {
        final template = TourTemplateModel.fromJson(data).toEntity();
        return ApiSuccess(data: template);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<TourTemplate>> deactivateTourTemplate(String id) async {
    final result = await _apiClient
        .patch<Map<String, dynamic>>('/tour-templates/$id/deactivate');

    return result.fold(
      onSuccess: (data) {
        final template = TourTemplateModel.fromJson(data).toEntity();
        return ApiSuccess(data: template);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<void>> deleteTourTemplate(String id) async {
    final result = await _apiClient.delete<void>('/tour-templates/$id');
    return result;
  }

  @override
  Future<ApiResult<List<TourTemplate>>> searchTourTemplates(
      String query) async {
    final result = await _apiClient.get<List<dynamic>>(
      '/tour-templates/search',
      queryParameters: {'q': query},
    );

    return result.fold(
      onSuccess: (data) {
        final templates = data
            .map((json) =>
                TourTemplateModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
        return ApiSuccess(data: templates);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }
}
