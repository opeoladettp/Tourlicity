import '../entities/registration.dart';
import '../../core/network/api_result.dart';

/// Repository interface for registration operations
abstract class RegistrationRepository {
  /// Register for a tour using join code
  Future<ApiResult<Registration>> registerForTour({
    required String joinCode,
    required String touristId,
    String? specialRequirements,
    String? emergencyContactName,
    String? emergencyContactPhone,
  });

  /// Get registration by ID
  Future<ApiResult<Registration>> getRegistrationById(String registrationId);

  /// Get registrations for a tourist
  Future<ApiResult<List<Registration>>> getRegistrationsByTourist(
    String touristId, {
    RegistrationStatus? status,
    int? limit,
    int? offset,
  });

  /// Get registrations for a tour (provider view)
  Future<ApiResult<List<Registration>>> getRegistrationsByTour(
    String customTourId, {
    RegistrationStatus? status,
    int? limit,
    int? offset,
  });

  /// Approve a registration (provider only)
  Future<ApiResult<Registration>> approveRegistration(
    String registrationId, {
    String? notes,
  });

  /// Reject a registration (provider only)
  Future<ApiResult<Registration>> rejectRegistration(
    String registrationId, {
    required String reason,
  });

  /// Cancel a registration (tourist or provider)
  Future<ApiResult<Registration>> cancelRegistration(String registrationId);

  /// Update registration details
  Future<ApiResult<Registration>> updateRegistration(
    String registrationId, {
    String? specialRequirements,
    String? emergencyContactName,
    String? emergencyContactPhone,
  });

  /// Get registration by confirmation code
  Future<ApiResult<Registration>> getRegistrationByConfirmationCode(
    String confirmationCode,
  );

  /// Mark registration as completed
  Future<ApiResult<Registration>> completeRegistration(String registrationId);

  /// Get registration statistics for a tour
  Future<ApiResult<Map<String, int>>> getRegistrationStats(String customTourId);
}