# Tourlicity App - Backend API Integration

## 🎯 Overview

The Tourlicity Flutter app is now **fully integrated** with your backend API running at `http://localhost:3000/api/v1`. This includes Google OAuth authentication, health monitoring, and all CRUD operations.

## ✅ **Integration Status: COMPLETE**

- **✅ Google OAuth**: Integrated with `/api/v1/auth/google`
- **✅ JWT Tokens**: Automatic refresh via `/api/v1/auth/refresh`
- **✅ Health Monitoring**: Real-time backend health checks
- **✅ All API Endpoints**: Tours, users, documents, messages
- **✅ Error Handling**: Comprehensive error management
- **✅ Testing**: Integration tests included

## 🚀 Quick Start

### Prerequisites

1. **Backend API**: Ensure your backend server is running at `http://localhost:3000`
2. **Flutter SDK**: Version 3.3.3 or higher
3. **Dependencies**: Run `flutter pub get` in the `tourlicity_app` directory

### Running the App

```bash
# Navigate to the app directory
cd tourlicity_app

# Install dependencies
flutter pub get

# Test backend integration
flutter test test/integration/backend_integration_test.dart

# Run the app
flutter run -d windows
```

### Testing Backend Integration

```bash
# Test backend connectivity and health
flutter test test/integration/backend_integration_test.dart

# Test specific backend endpoints
curl http://localhost:3000/health
curl http://localhost:3000/api-docs

# Expected output:
✅ Backend Health: HEALTHY (1.0.0)
✅ Backend connectivity test passed
```

## 🔧 Configuration

### Environment Settings

The app automatically detects the environment and uses appropriate API endpoints:

- **Development**: `http://localhost:3000/api/v1` (current)
- **Staging**: `https://staging-api.tourlicity.com/api/v1`
- **Production**: `https://api.tourlicity.com/api/v1`

Configuration file: `lib/core/config/environment_config.dart`

### API Client

The app uses Dio HTTP client with the following features:

- Automatic token refresh
- Request/response interceptors
- Error handling
- Certificate pinning (production only)
- Request signing for critical operations

Main files:

- `lib/core/network/dio_api_client.dart`
- `lib/core/network/api_client.dart`
- `lib/core/network/api_result.dart`

## 📡 API Endpoints

### Authentication

- `POST /auth/login` - User authentication
- `POST /auth/refresh` - Token refresh
- `POST /auth/logout` - User logout
- `POST /auth/register` - User registration

### Tours

- `GET /tours` - List tours
- `POST /tours` - Create tour
- `GET /tours/{id}` - Get tour details
- `PUT /tours/{id}` - Update tour
- `DELETE /tours/{id}` - Delete tour
- `GET /tours/join/{code}` - Get tour by join code

### Registrations

- `GET /registrations` - List user registrations
- `POST /registrations` - Create registration
- `PUT /registrations/{id}` - Update registration
- `DELETE /registrations/{id}` - Cancel registration

### Documents

- `GET /documents` - List documents
- `POST /documents` - Upload document
- `GET /documents/{id}` - Download document
- `DELETE /documents/{id}` - Delete document

### Messages

- `GET /messages` - List messages
- `POST /messages` - Send message
- `PUT /messages/{id}/read` - Mark as read
- `DELETE /messages/{id}` - Delete message

## 🏗️ Architecture

### Data Layer

```
lib/data/
├── models/          # API response models
├── repositories/    # Repository implementations
└── datasources/     # API data sources
```

### Domain Layer

```
lib/domain/
├── entities/        # Business entities
├── repositories/    # Repository interfaces
└── usecases/        # Business logic
```

### Presentation Layer

```
lib/presentation/
├── blocs/          # State management (BLoC)
├── pages/          # Screen widgets
└── widgets/        # Reusable UI components
```

### Core Layer

```
lib/core/
├── network/        # API client and networking
├── config/         # Environment configuration
├── security/       # Security features
└── services/       # Shared services
```

## 🔐 Security Features

### Token Management

- Secure token storage using `flutter_secure_storage`
- Automatic token refresh
- Session validation

### Request Security

- Certificate pinning (production)
- Request signing for critical operations
- Input validation
- Biometric authentication support

### Data Protection

- Encrypted local storage
- Secure session management
- PII data handling

## 🧪 Testing

### Unit Tests

```bash
flutter test test/unit/
```

### Integration Tests

```bash
flutter test test/integration/
```

### API Connectivity Test

```bash
flutter test test/integration/api_connectivity_test.dart
```

### Performance Tests

```bash
flutter test test/performance/
```

## 🐛 Troubleshooting

### Common Issues

#### 1. API Connection Failed

**Error**: `Connection refused` or `Network error`
**Solution**:

- Ensure backend server is running at `http://localhost:3000`
- Check firewall settings
- Verify API health endpoint: `curl http://localhost:3000/api/v1/health`

#### 2. Authentication Issues

**Error**: `401 Unauthorized`
**Solution**:

- Check token storage and refresh logic
- Verify API authentication endpoints
- Clear app data and re-authenticate

#### 3. Build Errors

**Error**: Various compilation errors
**Solution**:

- Run `flutter clean && flutter pub get`
- Check Flutter SDK version compatibility
- Verify all dependencies are properly installed

#### 4. Test Failures

**Error**: Mock or test-related errors
**Solution**:

- Generate missing mock files: `dart run build_runner build`
- Update test dependencies
- Fix constructor parameter mismatches

### Debug Mode

Enable debug logging by setting environment:

```bash
flutter run --dart-define=ENVIRONMENT=development
```

### Network Debugging

Monitor API calls using Flutter Inspector or add logging:

```dart
// In dio_api_client.dart
_dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

## 📊 Performance Monitoring

### Metrics Tracked

- API response times
- Memory usage
- Network bandwidth
- Error rates
- User interactions

### Monitoring Services

- Firebase Performance (production)
- Firebase Crashlytics (error tracking)
- Firebase Analytics (user behavior)

## 🔄 State Management

The app uses BLoC pattern for state management:

### Key BLoCs

- `AuthBloc` - Authentication state
- `CustomTourBloc` - Tour management
- `RegistrationBloc` - Registration handling
- `DocumentBloc` - Document operations
- `MessageBloc` - Messaging system

### State Flow

```
User Action → Event → BLoC → Repository → API → Response → State → UI Update
```

## 📱 Offline Support

### Features

- Local data caching
- Offline-first architecture
- Sync when online
- Conflict resolution

### Implementation

- SQLite local database
- Background sync service
- Connectivity monitoring
- Data versioning

## 🚀 Deployment

### Development

- Uses localhost API
- Debug logging enabled
- Hot reload supported

### Staging

- Uses staging API endpoints
- Performance monitoring enabled
- Beta testing features

### Production

- Uses production API endpoints
- Full security features enabled
- Analytics and crash reporting
- Certificate pinning active

## 📞 Support

### Issues and Questions

1. Check this documentation first
2. Review the `API_INTEGRATION_FIXES_SUMMARY.md` file
3. Check Flutter and Dart documentation
4. Review API documentation from backend team

### Development Team Contacts

- Frontend: Flutter development team
- Backend: API development team
- DevOps: Infrastructure team

---

**Last Updated**: January 2024
**Flutter Version**: 3.3.3+
**Dart Version**: 3.3.3+
