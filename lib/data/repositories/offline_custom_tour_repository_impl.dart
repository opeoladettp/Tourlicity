import '../../core/network/api_result.dart';
import '../../core/repositories/offline_repository_base.dart';
import '../../domain/entities/custom_tour.dart';
import '../../domain/repositories/custom_tour_repository.dart';
import '../models/custom_tour_model.dart';

/// Offline-aware implementation of CustomTourRepository
class OfflineCustomTourRepositoryImpl extends OfflineRepositoryBase
    implements CustomTourRepository {
  OfflineCustomTourRepositoryImpl({
    required super.apiClient,
    required super.cacheService,
    required super.connectivityService,
    required super.syncService,
  });

  @override
  String get cacheTableName => 'cache_tours';

  @override
  Future<ApiResult<List<CustomTour>>> getCustomTours({
    String? providerId,
    TourStatus? status,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (providerId != null) queryParameters['provider_id'] = providerId;
      if (status != null) queryParameters['status'] = status.name;
      if (page != null) queryParameters['page'] = page;
      if (limit != null) queryParameters['limit'] = limit;

      final data = await getDataWithCache(
        endpoint: '/custom-tours',
        apiCall: () async {
          final result = await apiClient.get<List<dynamic>>(
            '/custom-tours',
            queryParameters: queryParameters,
          );
          
          return result.fold(
            onSuccess: (data) => data.cast<Map<String, dynamic>>(),
            onFailure: (error) => throw Exception(error),
          );
        },
      );

      final customTours = data
          .map((json) => CustomTourModel.fromJson(json))
          .map((model) => model.toEntity())
          .toList();

      // Apply local filtering if needed
      var filteredTours = customTours;
      if (providerId != null) {
        filteredTours = filteredTours
            .where((tour) => tour.providerId == providerId)
            .toList();
      }
      if (status != null) {
        filteredTours = filteredTours
            .where((tour) => tour.status == status)
            .toList();
      }

      return ApiSuccess(data: filteredTours);
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<CustomTour>> getCustomTourById(String id) async {
    try {
      final data = await getItemWithCache(
        id: id,
        endpoint: '/custom-tours/$id',
        apiCall: () async {
          final result = await apiClient.get<Map<String, dynamic>>('/custom-tours/$id');
          return result.fold(
            onSuccess: (data) => data,
            onFailure: (error) => throw Exception(error),
          );
        },
      );

      if (data == null) {
        return const ApiFailure(message: 'Tour not found');
      }

      final model = CustomTourModel.fromJson(data);
      return ApiSuccess(data: model.toEntity());
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<CustomTour>> getCustomTourByJoinCode(String joinCode) async {
    try {
      // For join code lookup, always try API first if online
      if (connectivityService.isOnline) {
        final result = await apiClient.get<Map<String, dynamic>>(
          '/custom-tours/join/$joinCode',
        );

        return result.fold(
          onSuccess: (data) {
            final model = CustomTourModel.fromJson(data);
            // Cache the result
            cacheService.cacheData(
              table: cacheTableName,
              key: model.id,
              data: data,
            );
            return ApiSuccess(data: model.toEntity());
          },
          onFailure: (error) => ApiFailure(message: error),
        );
      } else {
        // If offline, search in cached tours
        final cachedTours = await cacheService.getCachedTours();
        final tour = cachedTours.firstWhere(
          (tour) => tour['join_code'] == joinCode,
          orElse: () => <String, dynamic>{},
        );

        if (tour.isEmpty) {
          return const ApiFailure(message: 'Tour not found offline');
        }

        final model = CustomTourModel.fromJson(tour);
        return ApiSuccess(data: model.toEntity());
      }
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<CustomTour>> createCustomTour(CustomTour customTour) async {
    try {
      final model = CustomTourModel.fromEntity(customTour);
      final data = await createItemWithSync(
        endpoint: '/custom-tours',
        data: model.toJson(),
        apiCall: () async {
          final result = await apiClient.post<Map<String, dynamic>>(
            '/custom-tours',
            data: model.toJson(),
          );
          return result.fold(
            onSuccess: (data) => data,
            onFailure: (error) => throw Exception(error),
          );
        },
      );

      if (data == null) {
        return const ApiFailure(message: 'Failed to create tour');
      }

      final responseModel = CustomTourModel.fromJson(data);
      return ApiSuccess(data: responseModel.toEntity());
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<CustomTour>> updateCustomTour(CustomTour customTour) async {
    try {
      final model = CustomTourModel.fromEntity(customTour);
      final data = await updateItemWithSync(
        id: customTour.id,
        endpoint: '/custom-tours/${customTour.id}',
        data: model.toJson(),
        apiCall: () async {
          final result = await apiClient.put<Map<String, dynamic>>(
            '/custom-tours/${customTour.id}',
            data: model.toJson(),
          );
          return result.fold(
            onSuccess: (data) => data,
            onFailure: (error) => throw Exception(error),
          );
        },
      );

      if (data == null) {
        return const ApiFailure(message: 'Failed to update tour');
      }

      final responseModel = CustomTourModel.fromJson(data);
      return ApiSuccess(data: responseModel.toEntity());
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<void>> deleteCustomTour(String id) async {
    try {
      await deleteItemWithSync(
        id: id,
        endpoint: '/custom-tours/$id',
        apiCall: () async {
          final result = await apiClient.delete('/custom-tours/$id');
          return result.fold(
            onSuccess: (_) => null,
            onFailure: (error) => throw Exception(error),
          );
        },
      );

      return const ApiSuccess(data: null);
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<CustomTour>> updateTourStatus(
    String id,
    TourStatus status,
  ) async {
    try {
      final data = await updateItemWithSync(
        id: id,
        endpoint: '/custom-tours/$id/status',
        data: {'status': status.name},
        apiCall: () async {
          final result = await apiClient.patch<Map<String, dynamic>>(
            '/custom-tours/$id/status',
            data: {'status': status.name},
          );
          return result.fold(
            onSuccess: (data) => data,
            onFailure: (error) => throw Exception(error),
          );
        },
      );

      if (data == null) {
        return const ApiFailure(message: 'Failed to update tour status');
      }

      final model = CustomTourModel.fromJson(data);
      return ApiSuccess(data: model.toEntity());
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
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
    try {
      final data = await updateItemWithSync(
        id: id,
        endpoint: '/custom-tours/$id/tourist-count',
        data: {'current_tourists': count},
        apiCall: () async {
          final result = await apiClient.patch<Map<String, dynamic>>(
            '/custom-tours/$id/tourist-count',
            data: {'current_tourists': count},
          );
          return result.fold(
            onSuccess: (data) => data,
            onFailure: (error) => throw Exception(error),
          );
        },
      );

      if (data == null) {
        return const ApiFailure(message: 'Failed to update tourist count');
      }

      final model = CustomTourModel.fromJson(data);
      return ApiSuccess(data: model.toEntity());
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }

  @override
  Future<ApiResult<CustomTour>> generateNewJoinCode(String id) async {
    try {
      // This operation requires online connectivity
      if (!connectivityService.isOnline) {
        return const ApiFailure(message: 'This operation requires internet connection');
      }

      final result = await apiClient.post<Map<String, dynamic>>(
        '/custom-tours/$id/generate-join-code',
      );

      return result.fold(
        onSuccess: (data) {
          final model = CustomTourModel.fromJson(data);
          // Update cache with new join code
          cacheService.cacheData(
            table: cacheTableName,
            key: id,
            data: data,
          );
          return ApiSuccess(data: model.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
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
    try {
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

      final data = await getDataWithCache(
        endpoint: '/custom-tours/search',
        apiCall: () async {
          final result = await apiClient.get<List<dynamic>>(
            '/custom-tours/search',
            queryParameters: queryParameters,
          );
          return result.fold(
            onSuccess: (data) => data.cast<Map<String, dynamic>>(),
            onFailure: (error) => throw Exception(error),
          );
        },
      );

      final customTours = data
          .map((json) => CustomTourModel.fromJson(json))
          .map((model) => model.toEntity())
          .toList();

      // Apply local filtering for offline search
      var filteredTours = customTours;
      
      if (query != null && query.isNotEmpty) {
        filteredTours = filteredTours.where((tour) =>
          tour.tourName.toLowerCase().contains(query.toLowerCase()) ||
          (tour.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList();
      }

      if (tags != null && tags.isNotEmpty) {
        filteredTours = filteredTours.where((tour) =>
          tour.tags.any((tag) => tags.contains(tag))
        ).toList();
      }

      if (status != null) {
        filteredTours = filteredTours.where((tour) => tour.status == status).toList();
      }

      if (startDateFrom != null) {
        filteredTours = filteredTours.where((tour) =>
          tour.startDate.isAfter(startDateFrom) || tour.startDate.isAtSameMomentAs(startDateFrom)
        ).toList();
      }

      if (startDateTo != null) {
        filteredTours = filteredTours.where((tour) =>
          tour.startDate.isBefore(startDateTo) || tour.startDate.isAtSameMomentAs(startDateTo)
        ).toList();
      }

      if (minPrice != null) {
        filteredTours = filteredTours.where((tour) => tour.pricePerPerson >= minPrice).toList();
      }

      if (maxPrice != null) {
        filteredTours = filteredTours.where((tour) => tour.pricePerPerson <= maxPrice).toList();
      }

      return ApiSuccess(data: filteredTours);
    } catch (e) {
      return ApiFailure(message: e.toString());
    }
  }
}