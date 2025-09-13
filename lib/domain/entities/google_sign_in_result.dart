import 'package:equatable/equatable.dart';

/// Result from Google Sign-In containing tokens and user info
class GoogleSignInResult extends Equatable {
  const GoogleSignInResult({
    required this.idToken,
    required this.accessToken,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  final String idToken;
  final String accessToken;
  final String email;
  final String displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [
        idToken,
        accessToken,
        email,
        displayName,
        photoUrl,
      ];
}
