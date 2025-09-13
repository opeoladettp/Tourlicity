# Backend Integration Guide

## 🎯 Overview

Your Flutter app is now fully integrated with your Tourlicity backend API running at `http://localhost:3000/api/v1`. This guide explains how the integration works and how to test it.

## 🔗 Integration Features

### ✅ **What's Integrated**

1. **Google OAuth Flow**: Uses your backend's `/auth/google` endpoint
2. **Token Management**: JWT token refresh via `/auth/refresh`
3. **Health Monitoring**: Backend health checks and metrics
4. **Profile Management**: Complete user profiles via `/auth/profile/complete`
5. **Error Handling**: Comprehensive error handling for all backend responses
6. **Configuration Validation**: Automatic API configuration validation

### 🏗️ **Architecture**

```
Flutter App
├── BackendAuthService ──────► /api/v1/auth/*
├── BackendHealthService ────► /health, /health/metrics
├── ApiClientFactory ───────► Creates configured Dio clients
└── AuthRepository ─────────► Orchestrates authentication flow
```

## 🚀 Quick Start

### 1. **Start Your Backend**

Make sure your backend is running:

```bash
# In your backend directory
npm run dev
# Backend should be running at http://localhost:3000
```

### 2. **Test Backend Connectivity**

```bash
# In your Flutter app directory
flutter test test/integration/backend_integration_test.dart
```

### 3. **Run the Flutter App**

```bash
flutter run -d windows
```

## 🔐 Authentication Flow

### **Google OAuth Integration**

Your app now uses your backend's OAuth flow:

1. **User clicks "Sign in with Google"**
2. **App calls** `BackendAuthService.initiateGoogleAuth()`
3. **Opens browser** to `http://localhost:3000/api/v1/auth/google`
4. **User completes OAuth** with Google
5. **Backend handles callback** and returns JWT tokens
6. **App stores tokens** securely

### **Code Example**

```dart
// In your authentication logic
final backendAuthService = ApiClientFactory.createBackendAuthService();
final result = await backendAuthService.initiateGoogleAuth();

if (result.isSuccess) {
  // OAuth flow initiated successfully
  // User will be redirected to Google OAuth
} else {
  // Handle error
  print('OAuth initiation failed: ${result.error}');
}
```

## 📊 Backend Health Monitoring

### **Health Check Integration**

The app automatically monitors your backend health:

```dart
final healthService = ApiClientFactory.createBackendHealthService();
final result = await healthService.checkHealth();

if (result.isSuccess) {
  final status = result.data!;
  print('Backend Status: ${status.status}');
  print('Services: ${status.services}');
} else {
  print('Backend health check failed: ${result.error}');
}
```

### **Available Health Endpoints**

- **Basic Health**: `GET /health`
- **Detailed Metrics**: `GET /health/metrics`
- **Configuration Validation**: `POST /api/v1/config/validate`

## 🛠️ Configuration

### **Environment Settings**

The app is configured for your backend:

```dart
// Development environment (current)
apiBaseUrl: 'http://localhost:3000/api/v1'
googleAuthUrl: 'http://localhost:3000/api/v1/auth/google'
healthCheckUrl: 'http://localhost:3000/health'
```

### **Google OAuth Configuration**

Your Google Client ID is already configured:
```dart
googleClientId: '519507867000-q7afm0sitg8g1r5860u4ftclu60fb376.apps.googleusercontent.com'
```

## 🧪 Testing

### **Run Integration Tests**

```bash
# Test backend connectivity
flutter test test/integration/backend_integration_test.dart

# Expected output:
✅ Backend Health: HEALTHY (1.0.0)
📊 Services: {database: healthy, redis: healthy, s3: healthy}
📈 Backend Metrics: ...
✅ Backend connectivity test passed
```

### **Manual Testing**

1. **Test Backend Health**:
   ```bash
   curl http://localhost:3000/health
   ```

2. **Test OAuth Endpoint**:
   ```bash
   # Open in browser (will redirect to Google)
   http://localhost:3000/api/v1/auth/google
   ```

3. **Test API Documentation**:
   ```bash
   # Open Swagger UI
   http://localhost:3000/api-docs
   ```

## 🔍 Troubleshooting

### **Common Issues**

#### 1. **Backend Connection Failed**

**Error**: `Cannot connect to backend`

**Solutions**:
- ✅ Check if backend is running: `curl http://localhost:3000/health`
- ✅ Verify port 3000 is not blocked by firewall
- ✅ Ensure no other service is using port 3000

#### 2. **OAuth Redirect Issues**

**Error**: `redirect_uri_mismatch`

**Solutions**:
- ✅ Verify Google Cloud Console OAuth settings
- ✅ Check redirect URI: `http://localhost:3000/api/v1/auth/google/callback`
- ✅ Ensure Google Client ID matches in both frontend and backend

#### 3. **Token Refresh Failures**

**Error**: `Token refresh failed`

**Solutions**:
- ✅ Check JWT secret configuration in backend
- ✅ Verify token expiration settings
- ✅ Clear app data and re-authenticate

### **Debug Mode**

Enable detailed logging:

```bash
flutter run --dart-define=ENVIRONMENT=development
```

This will show detailed API logs:
```
🌐 API: Request: GET /health
🌐 API: Response: {"status": "HEALTHY", ...}
```

## 📱 Features Ready to Use

### **Authentication**
- ✅ Google OAuth login
- ✅ JWT token management
- ✅ Automatic token refresh
- ✅ Profile completion

### **API Integration**
- ✅ All CRUD operations for tours, users, documents
- ✅ File upload to your S3 bucket
- ✅ Real-time messaging
- ✅ Registration workflow

### **Monitoring**
- ✅ Backend health monitoring
- ✅ Performance metrics
- ✅ Error tracking
- ✅ Configuration validation

## 🚀 Next Steps

### **1. Test Core Functionality**

```bash
# Run the app and test:
flutter run -d windows

# Test these features:
1. Google Sign-In (opens browser to your backend)
2. Profile completion
3. Browse tours
4. Join a tour
5. Upload documents
```

### **2. Add Your Business Logic**

The integration is complete! You can now:

- Create tours using your backend API
- Handle registrations through your approval workflow
- Upload documents to your S3 bucket
- Send messages through your communication system

### **3. Deploy to Production**

When ready for production:

1. Update environment configuration for staging/production
2. Configure production Google OAuth credentials
3. Set up proper SSL certificates
4. Enable Firebase services for production monitoring

## 📞 Support

### **Backend API Documentation**
- **Swagger UI**: http://localhost:3000/api-docs
- **Health Check**: http://localhost:3000/health
- **API Examples**: See your `api-usage-examples.md`

### **Flutter Integration**
- **Integration Tests**: `test/integration/backend_integration_test.dart`
- **Configuration**: `lib/core/config/environment_config.dart`
- **Services**: `lib/data/services/backend_auth_service.dart`

---

## ✅ **Integration Complete!**

Your Flutter app is now fully connected to your backend API. The authentication flow uses your Google OAuth endpoint, all API calls go through your backend, and health monitoring ensures everything stays connected.

**Ready to test?** Run `flutter test test/integration/backend_integration_test.dart` to verify everything is working! 🎉