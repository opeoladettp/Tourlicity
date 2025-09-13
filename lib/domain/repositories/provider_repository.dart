import '../entities/provider.dart';
import '../../core/network/api_result.dart';

/// Repository interface for provider management operations
abstract class ProviderRepository {
  /// Get all providers with optional filtering
  Future<ApiResult<List<Provider>>> getProviders({
    String? search,
    String? country,
    bool? isActive,
    int? page,
    int? limit,
  });

  /// Get a specific provider by ID
  Future<ApiResult<Provider>> getProviderById(String id);

  /// Create a new provider
  Future<ApiResult<Provider>> createProvider(Provider provider);

  /// Update an existing provider
  Future<ApiResult<Provider>> updateProvider(String id, Provider provider);

  /// Activate a provider
  Future<ApiResult<Provider>> activateProvider(String id);

  /// Deactivate a provider
  Future<ApiResult<Provider>> deactivateProvider(String id);

  /// Delete a provider (soft delete)
  Future<ApiResult<void>> deleteProvider(String id);

  /// Search providers by name or code
  Future<ApiResult<List<Provider>>> searchProviders(String query);
}
