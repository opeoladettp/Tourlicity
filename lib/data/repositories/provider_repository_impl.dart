import '../../core/network/api_client.dart';
import '../../core/network/api_result.dart';
import '../../domain/entities/provider.dart';
import '../../domain/repositories/provider_repository.dart';
import '../models/provider_model.dart';

/// Implementation of ProviderRepository using API client
class ProviderRepositoryImpl implements ProviderRepository {
  final ApiClient _apiClient;

  const ProviderRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<ApiResult<List<Provider>>> getProviders({
    String? search,
    String? country,
    bool? isActive,
    int? page,
    int? limit,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }
    if (country != null && country.isNotEmpty) {
      queryParameters['country'] = country;
    }
    if (isActive != null) {
      queryParameters['is_active'] = isActive;
    }
    if (page != null) {
      queryParameters['page'] = page;
    }
    if (limit != null) {
      queryParameters['limit'] = limit;
    }

    final result = await _apiClient.get<List<dynamic>>('/providers',
        queryParameters: queryParameters);

    return result.fold(
      onSuccess: (data) {
        final providers = data
            .map((json) =>
                ProviderModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
        return ApiSuccess(data: providers);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<Provider>> getProviderById(String id) async {
    final result = await _apiClient.get<Map<String, dynamic>>('/providers/$id');

    return result.fold(
      onSuccess: (data) {
        final provider = ProviderModel.fromJson(data).toEntity();
        return ApiSuccess(data: provider);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<Provider>> createProvider(Provider provider) async {
    final providerModel = ProviderModel.fromEntity(provider);
    final requestData = providerModel.toJson();

    // Remove id and created_date for creation
    requestData.remove('id');
    requestData.remove('created_date');

    final result = await _apiClient.post<Map<String, dynamic>>(
      '/providers',
      data: requestData,
    );

    return result.fold(
      onSuccess: (data) {
        final provider = ProviderModel.fromJson(data).toEntity();
        return ApiSuccess(data: provider);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<Provider>> updateProvider(
      String id, Provider provider) async {
    final providerModel = ProviderModel.fromEntity(provider);
    final requestData = providerModel.toJson();

    // Remove fields that shouldn't be updated
    requestData.remove('id');
    requestData.remove('created_date');
    requestData.remove('provider_code');

    final result = await _apiClient.put<Map<String, dynamic>>(
      '/providers/$id',
      data: requestData,
    );

    return result.fold(
      onSuccess: (data) {
        final provider = ProviderModel.fromJson(data).toEntity();
        return ApiSuccess(data: provider);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<Provider>> activateProvider(String id) async {
    final result =
        await _apiClient.patch<Map<String, dynamic>>('/providers/$id/activate');

    return result.fold(
      onSuccess: (data) {
        final provider = ProviderModel.fromJson(data).toEntity();
        return ApiSuccess(data: provider);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<Provider>> deactivateProvider(String id) async {
    final result = await _apiClient
        .patch<Map<String, dynamic>>('/providers/$id/deactivate');

    return result.fold(
      onSuccess: (data) {
        final provider = ProviderModel.fromJson(data).toEntity();
        return ApiSuccess(data: provider);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }

  @override
  Future<ApiResult<void>> deleteProvider(String id) async {
    final result = await _apiClient.delete<void>('/providers/$id');
    return result;
  }

  @override
  Future<ApiResult<List<Provider>>> searchProviders(String query) async {
    final result = await _apiClient.get<List<dynamic>>(
      '/providers/search',
      queryParameters: {'q': query},
    );

    return result.fold(
      onSuccess: (data) {
        final providers = data
            .map((json) => ProviderModel.fromJson(json as Map<String, dynamic>))
            .map((model) => model.toEntity())
            .toList();
        return ApiSuccess(data: providers);
      },
      onFailure: (error) => ApiFailure(message: error),
    );
  }
}
