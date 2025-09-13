import '../entities/user.dart';
import '../../core/network/api_result.dart';

/// Repository interface for user operations
abstract class UserRepository {
  /// Get current user profile
  Future<ApiResult<User>> getCurrentUser();

  /// Get user profile by ID
  Future<ApiResult<User>> getUserProfile(String userId);

  /// Update user profile
  Future<ApiResult<User>> updateUserProfile(User user);

  /// Update profile with specific fields
  Future<ApiResult<User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  });

  /// Complete user profile
  Future<ApiResult<User>> completeUserProfile({
    required String userId,
    required String name,
    String? phoneNumber,
    String? profilePicture,
  });

  /// Complete profile with specific fields
  Future<ApiResult<User>> completeProfile({
    required String firstName,
    required String lastName,
    String? phone,
  });

  /// Check if profile is complete
  Future<ApiResult<bool>> isProfileComplete();

  /// Upload profile picture
  Future<ApiResult<String>> uploadProfilePicture(String filePath);

  /// Delete user account
  Future<ApiResult<void>> deleteUserAccount(String userId);
}
