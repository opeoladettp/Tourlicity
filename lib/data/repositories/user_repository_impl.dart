import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../core/network/api_result.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

/// Implementation of UserRepository
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<ApiResult<User>> getCurrentUser() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/users/me');

      return response.fold(
        onSuccess: (data) {
          final userModel = UserModel.fromJson(data);
          return ApiSuccess(data: userModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(message: 'Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['name'] = '$firstName ${lastName ?? ''}';
      if (phone != null) data['phone_number'] = phone;

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/users/me',
        data: data,
      );

      return response.fold(
        onSuccess: (responseData) {
          final userModel = UserModel.fromJson(responseData);
          return ApiSuccess(data: userModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(message: 'Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<User>> completeProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      final data = {
        'name': '$firstName $lastName',
        if (phone != null) 'phone_number': phone,
        'is_profile_complete': true,
      };

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/users/me/complete-profile',
        data: data,
      );

      return response.fold(
        onSuccess: (responseData) {
          final userModel = UserModel.fromJson(responseData);
          return ApiSuccess(data: userModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(message: 'Failed to complete profile: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<bool>> isProfileComplete() async {
    try {
      final userResult = await getCurrentUser();
      return userResult.fold(
        onSuccess: (user) => ApiSuccess(data: user.isProfileComplete),
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
          message: 'Failed to check profile completion: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<User>> getUserProfile(String userId) async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('/users/$userId');

      return response.fold(
        onSuccess: (data) {
          final userModel = UserModel.fromJson(data);
          return ApiSuccess(data: userModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(message: 'Failed to get user profile: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<User>> updateUserProfile(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final response = await _apiClient.put<Map<String, dynamic>>(
        '/users/${user.id}',
        data: userModel.toJson(),
      );

      return response.fold(
        onSuccess: (data) {
          final updatedUserModel = UserModel.fromJson(data);
          return ApiSuccess(data: updatedUserModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
          message: 'Failed to update user profile: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<User>> completeUserProfile({
    required String userId,
    required String name,
    String? phoneNumber,
    String? profilePicture,
  }) async {
    try {
      final data = {
        'name': name,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (profilePicture != null) 'profile_picture': profilePicture,
        'is_profile_complete': true,
      };

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/users/$userId/complete-profile',
        data: data,
      );

      return response.fold(
        onSuccess: (responseData) {
          final userModel = UserModel.fromJson(responseData);
          return ApiSuccess(data: userModel.toEntity());
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
          message: 'Failed to complete user profile: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<String>> uploadProfilePicture(String filePath) async {
    try {
      final response = await _apiClient.uploadFile<Map<String, dynamic>>(
        '/users/upload-profile-picture',
        filePath,
        fieldName: 'profile_picture',
      );

      return response.fold(
        onSuccess: (data) {
          final imageUrl = data['image_url'] as String;
          return ApiSuccess(data: imageUrl);
        },
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
          message: 'Failed to upload profile picture: ${e.toString()}');
    }
  }

  @override
  Future<ApiResult<void>> deleteUserAccount(String userId) async {
    try {
      final response = await _apiClient.delete<void>('/users/$userId');

      return response.fold(
        onSuccess: (_) => const ApiSuccess(data: null),
        onFailure: (error) => ApiFailure(message: error),
      );
    } catch (e) {
      return ApiFailure(
          message: 'Failed to delete user account: ${e.toString()}');
    }
  }
}
