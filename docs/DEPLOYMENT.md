# Tourlicity App Deployment Guide

## Overview

This document provides comprehensive instructions for deploying the Tourlicity Flutter application across different environments and platforms.

## Prerequisites

### Development Environment
- Flutter SDK 3.3.3 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile builds)
- Git
- Firebase CLI (for Firebase services)

### Build Tools
- Android SDK (API level 21+)
- Xcode 14+ (for iOS builds)
- CocoaPods (for iOS dependencies)

## Environment Configuration

### Available Environments
1. **Development** - Local development and testing
2. **Staging** - Pre-production testing
3. **Production** - Live application

### Environment Variables
Set the following environment variables for each environment:

```bash
# Development
ENVIRONMENT=development
API_BASE_URL=https://dev-api.tourlicity.com/api/v1
FIREBASE_PROJECT_ID=tourlicity-dev
GOOGLE_CLIENT_ID=dev-client-id.googleusercontent.com

# Staging
ENVIRONMENT=staging
API_BASE_URL=https://staging-api.tourlicity.com/api/v1
FIREBASE_PROJECT_ID=tourlicity-staging
GOOGLE_CLIENT_ID=staging-client-id.googleusercontent.com

# Production
ENVIRONMENT=production
API_BASE_URL=https://api.tourlicity.com/api/v1
FIREBASE_PROJECT_ID=tourlicity-prod
GOOGLE_CLIENT_ID=prod-client-id.googleusercontent.com
```

## Build Process

### Automated Build Script
Use the provided build script for consistent builds:

```bash
# Build for production Android
./scripts/build_release.sh production android

# Build for staging iOS
./scripts/build_release.sh staging ios

# Build for development web
./scripts/build_release.sh development web
```

### Manual Build Commands

#### Android
```bash
# Development
flutter build apk --release --dart-define=ENVIRONMENT=development --flavor=development

# Staging
flutter build apk --release --dart-define=ENVIRONMENT=staging --flavor=staging

# Production (AAB for Play Store)
flutter build appbundle --release --dart-define=ENVIRONMENT=production --flavor=production
```

#### iOS
```bash
# All environments
flutter build ios --release --dart-define=ENVIRONMENT=production
```

#### Web
```bash
# All environments
flutter build web --release --dart-define=ENVIRONMENT=production --web-renderer canvaskit
```

## Deployment Steps

### 1. Pre-deployment Checklist
- [ ] All tests passing (`flutter test`)
- [ ] Code analysis clean (`flutter analyze`)
- [ ] Environment configuration validated
- [ ] Firebase configuration updated
- [ ] API endpoints accessible
- [ ] Certificates and signing keys available

### 2. Android Deployment

#### Google Play Store (Production)
1. Build production AAB:
   ```bash
   flutter build appbundle --release --dart-define=ENVIRONMENT=production --flavor=production
   ```

2. Upload to Google Play Console:
   - Navigate to Google Play Console
   - Select Tourlicity app
   - Go to Release > Production
   - Upload `app-production-release.aab`
   - Fill release notes and metadata
   - Submit for review

#### Internal Testing (Staging)
1. Build staging APK:
   ```bash
   flutter build apk --release --dart-define=ENVIRONMENT=staging --flavor=staging
   ```

2. Distribute via Firebase App Distribution or internal channels

### 3. iOS Deployment

#### App Store (Production)
1. Build iOS app:
   ```bash
   flutter build ios --release --dart-define=ENVIRONMENT=production
   ```

2. Archive in Xcode:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select "Any iOS Device" as target
   - Product > Archive
   - Upload to App Store Connect

#### TestFlight (Staging)
1. Follow same build process
2. Upload to TestFlight for beta testing

### 4. Web Deployment

#### Firebase Hosting
1. Build web app:
   ```bash
   flutter build web --release --dart-define=ENVIRONMENT=production
   ```

2. Deploy to Firebase:
   ```bash
   firebase deploy --only hosting
   ```

## Configuration Management

### Firebase Configuration
Each environment requires separate Firebase projects:

1. **Development**: `tourlicity-dev`
2. **Staging**: `tourlicity-staging`
3. **Production**: `tourlicity-prod`

### Google Services Configuration
- Place `google-services.json` (Android) in `android/app/src/{flavor}/`
- Place `GoogleService-Info.plist` (iOS) in `ios/Runner/`

### Signing Configuration

#### Android Signing
1. Create keystore for each environment:
   ```bash
   keytool -genkey -v -keystore tourlicity-{env}.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tourlicity-{env}
   ```

2. Configure in `android/local.properties`:
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=tourlicity-production
   storeFile=../keys/tourlicity-production.jks
   ```

#### iOS Signing
- Configure signing certificates in Xcode
- Use automatic signing for development
- Use manual signing for production with distribution certificates

## Monitoring and Rollback

### Post-deployment Monitoring
1. **Crashlytics**: Monitor crash reports
2. **Analytics**: Track user engagement
3. **Performance**: Monitor app performance metrics
4. **API Monitoring**: Ensure backend connectivity

### Rollback Procedure
1. **Google Play Store**: 
   - Use "Release management" to rollback to previous version
   - Or upload hotfix version with incremented version code

2. **App Store**:
   - Submit hotfix version for expedited review
   - Or remove app from sale temporarily

3. **Web**:
   - Rollback Firebase Hosting deployment:
     ```bash
     firebase hosting:clone source-site-id:source-version-id target-site-id
     ```

## Troubleshooting

### Common Issues

#### Build Failures
- **Gradle build failed**: Check Android SDK and build tools versions
- **CocoaPods issues**: Run `cd ios && pod install --repo-update`
- **Flutter version mismatch**: Ensure Flutter SDK version consistency

#### Deployment Issues
- **Signing errors**: Verify certificates and provisioning profiles
- **Upload failures**: Check app bundle size and metadata
- **Firebase errors**: Verify project configuration and permissions

#### Runtime Issues
- **API connectivity**: Verify environment URLs and network configuration
- **Authentication failures**: Check Google Sign-In configuration
- **Crashes**: Monitor Crashlytics and fix critical issues

### Support Contacts
- **Development Team**: dev@tourlicity.com
- **DevOps Team**: devops@tourlicity.com
- **QA Team**: qa@tourlicity.com

## Security Considerations

### Production Security
- Enable certificate pinning
- Use secure storage for sensitive data
- Implement proper session management
- Regular security audits

### Environment Isolation
- Separate Firebase projects per environment
- Different API endpoints and databases
- Isolated user data and testing data

## Performance Optimization

### Build Optimization
- Enable R8/ProGuard for Android release builds
- Use `--split-per-abi` for smaller APK sizes
- Optimize images and assets
- Enable tree shaking for web builds

### Runtime Optimization
- Implement lazy loading
- Use cached network images
- Optimize list rendering
- Monitor memory usage

## Compliance and Legal

### App Store Guidelines
- Follow Google Play and App Store policies
- Include required privacy policy
- Implement proper data handling
- Age-appropriate content rating

### Data Protection
- GDPR compliance for EU users
- CCPA compliance for California users
- Proper data encryption and storage
- User consent management

---

**Last Updated**: December 2024  
**Version**: 1.0.0  
**Maintained by**: Tourlicity Development Team