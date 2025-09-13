#!/bin/bash

# Build script for different environments
# Usage: ./scripts/build_release.sh [environment] [platform]
# Example: ./scripts/build_release.sh production android

set -e

ENVIRONMENT=${1:-production}
PLATFORM=${2:-android}
BUILD_NUMBER=${3:-$(date +%s)}

echo "Building Tourlicity app for $ENVIRONMENT environment on $PLATFORM platform"

# Validate environment
case $ENVIRONMENT in
  development|staging|production)
    echo "Environment: $ENVIRONMENT"
    ;;
  *)
    echo "Invalid environment. Use: development, staging, or production"
    exit 1
    ;;
esac

# Validate platform
case $PLATFORM in
  android|ios|web)
    echo "Platform: $PLATFORM"
    ;;
  *)
    echo "Invalid platform. Use: android, ios, or web"
    exit 1
    ;;
esac

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean
flutter pub get

# Generate code if needed
echo "Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build for specific platform and environment
case $PLATFORM in
  android)
    echo "Building Android APK/AAB for $ENVIRONMENT..."
    if [ "$ENVIRONMENT" = "production" ]; then
      flutter build appbundle \
        --release \
        --dart-define=ENVIRONMENT=$ENVIRONMENT \
        --build-number=$BUILD_NUMBER \
        --flavor=production
      
      flutter build apk \
        --release \
        --dart-define=ENVIRONMENT=$ENVIRONMENT \
        --build-number=$BUILD_NUMBER \
        --flavor=production
    else
      flutter build apk \
        --release \
        --dart-define=ENVIRONMENT=$ENVIRONMENT \
        --build-number=$BUILD_NUMBER \
        --flavor=$ENVIRONMENT
    fi
    ;;
    
  ios)
    echo "Building iOS for $ENVIRONMENT..."
    flutter build ios \
      --release \
      --dart-define=ENVIRONMENT=$ENVIRONMENT \
      --build-number=$BUILD_NUMBER
    ;;
    
  web)
    echo "Building Web for $ENVIRONMENT..."
    flutter build web \
      --release \
      --dart-define=ENVIRONMENT=$ENVIRONMENT \
      --web-renderer canvaskit
    ;;
esac

echo "Build completed successfully!"
echo "Environment: $ENVIRONMENT"
echo "Platform: $PLATFORM"
echo "Build Number: $BUILD_NUMBER"

# Show build artifacts location
case $PLATFORM in
  android)
    echo "Android artifacts:"
    if [ "$ENVIRONMENT" = "production" ]; then
      echo "  - AAB: build/app/outputs/bundle/productionRelease/app-production-release.aab"
      echo "  - APK: build/app/outputs/flutter-apk/app-production-release.apk"
    else
      echo "  - APK: build/app/outputs/flutter-apk/app-$ENVIRONMENT-release.apk"
    fi
    ;;
  ios)
    echo "iOS artifacts: build/ios/iphoneos/Runner.app"
    ;;
  web)
    echo "Web artifacts: build/web/"
    ;;
esac