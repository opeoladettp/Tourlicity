class AppConstants {
  // API Configuration
  static const String baseUrlDev = 'http://localhost:3000/api/v1';
  static const String baseUrlStaging = 'https://staging-api.tourlicity.com/api/v1';
  static const String baseUrlProd = 'https://api.tourlicity.com/api/v1';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // App Configuration
  static const String appName = 'Tourlicity';
  static const int requestTimeoutSeconds = 30;
  static const int maxFileUploadSizeMB = 10;

  // Supported file types for document upload
  static const List<String> supportedFileTypes = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'doc',
    'docx'
  ];
}
