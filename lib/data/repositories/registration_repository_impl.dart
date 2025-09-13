import '../../domain/entities/registration.dart';
import '../../domain/repositories/registration_repository.dart';
import '../../core/network/api_result.dart';
import '../../core/network/api_client.dart';
import '../models/registration_model.dart';

/// Implementation of RegistrationRepository
class RegistrationRepositoryImpl implements RegistrationRepository {
  const RegistrationRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<ApiResult<Registration>> registerForTour({
    required String joinCode,
    required String touristId,
    String? specialRequirements,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      final requestData = {
        'join_code': joinCode,
        'tourist_id': touristId,
        if (specialRequirements != null) 'special_requirements': specialRequirements,
        if (emergencyContactName != null) 'emergency_contact_name': emergencyContactName,
        if (emergencyContactPhone != null) 'emergency_contact_phone': emergencyContactPhone,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/registrations',
        data: requestData,
      );

      return response.fold(
        onSuccess: (data) {
          final registrationModel = RegistrationModel.fromJson(data);
          return ApiSuccess(data: registrationModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to register for tour: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Registration>> getRegistrationById(String registrationId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/registrations/$registrationId',
      );

      return response.fold(
        onSuccess: (data) {
          final registrationModel = RegistrationModel.fromJson(data);
          return ApiSuccess(data: registrationModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get registration: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<List<Registration>>> getRegistrationsByTourist(
    String touristId, {
    RegistrationStatus? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'tourist_id': touristId,
        if (status != null) 'status': status.name,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/registrations',
        queryParameters: queryParameters,
      );

      return response.fold(
        onSuccess: (data) {
          final registrationsData = data['registrations'] as List<dynamic>;
          final registrations = registrationsData
              .map((json) => RegistrationModel.fromJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
          return ApiSuccess(data: registrations);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get tourist registrations: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<List<Registration>>> getRegistrationsByTour(
    String customTourId, {
    RegistrationStatus? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'custom_tour_id': customTourId,
        if (status != null) 'status': status.name,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/registrations',
        queryParameters: queryParameters,
      );

      return response.fold(
        onSuccess: (data) {
          final registrationsData = data['registrations'] as List<dynamic>;
          final registrations = registrationsData
              .map((json) => RegistrationModel.fromJson(json as Map<String, dynamic>))
              .map((model) => model.toEntity())
              .toList();
          return ApiSuccess(data: registrations);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get tour registrations: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Registration>> approveRegistration(
    String registrationId, {
    String? notes,
  }) async {
    try {
      final requestData = {
        'status': 'approved',
        if (notes != null) 'approval_notes': notes,
      };

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/registrations/$registrationId/status',
        data: requestData,
      );

      return response.fold(
        onSuccess: (data) {
          final registrationModel = RegistrationModel.fromJson(data);
          return ApiSuccess(data: registrationModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to approve registration: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Registration>> rejectRegistration(
    String registrationId, {
    required String reason,
  }) async {
    try {
      final requestData = {
        'status': 'rejected',
        'rejection_reason': reason,
      };

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/registrations/$registrationId/status',
        data: requestData,
      );

      return response.fold(
        onSuccess: (data) {
          final registrationModel = RegistrationModel.fromJson(data);
          return ApiSuccess(data: registrationModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to reject registration: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Registration>> cancelRegistration(String registrationId) async {
    try {
      final requestData = {
        'status': 'cancelled',
      };

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/registrations/$registrationId/status',
        data: requestData,
      );

      return response.fold(
        onSuccess: (data) {
          final registrationModel = RegistrationModel.fromJson(data);
          return ApiSuccess(data: registrationModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to cancel registration: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Registration>> updateRegistration(
    String registrationId, {
    String? specialRequirements,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      final requestData = <String, dynamic>{
        if (specialRequirements != null) 'special_requirements': specialRequirements,
        if (emergencyContactName != null) 'emergency_contact_name': emergencyContactName,
        if (emergencyContactPhone != null) 'emergency_contact_phone': emergencyContactPhone,
      };

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/registrations/$registrationId',
        data: requestData,
      );

      return response.fold(
        onSuccess: (data) {
          final registrationModel = RegistrationModel.fromJson(data);
          return ApiSuccess(data: registrationModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to update registration: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Registration>> getRegistrationByConfirmationCode(
    String confirmationCode,
  ) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/registrations/confirmation/$confirmationCode',
      );

      return response.fold(
        onSuccess: (data) {
          final registrationModel = RegistrationModel.fromJson(data);
          return ApiSuccess(data: registrationModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get registration by confirmation code: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Registration>> completeRegistration(String registrationId) async {
    try {
      final requestData = {
        'status': 'completed',
      };

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/registrations/$registrationId/status',
        data: requestData,
      );

      return response.fold(
        onSuccess: (data) {
          final registrationModel = RegistrationModel.fromJson(data);
          return ApiSuccess(data: registrationModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to complete registration: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ApiResult<Map<String, int>>> getRegistrationStats(String customTourId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/registrations/stats/$customTourId',
      );

      return response.fold(
        onSuccess: (data) {
          final stats = Map<String, int>.from(data);
          return ApiSuccess(data: stats);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
        message: 'Failed to get registration stats: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}