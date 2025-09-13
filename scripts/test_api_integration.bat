@echo off
REM API Integration Test Script for Windows
echo 🚀 Testing Tourlicity App API Integration
echo =========================================

REM Check if backend is running
echo 📡 Checking backend API availability...
curl -s http://localhost:3000/api/v1/health >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Backend API is running at http://localhost:3000/api/v1
) else (
    echo ❌ Backend API is not accessible at http://localhost:3000/api/v1
    echo    Please ensure your backend server is running
    pause
    exit /b 1
)

REM Run Flutter app in debug mode
echo.
echo 🏃 Starting Flutter app...
echo    The app is configured to use http://localhost:3000/api/v1
echo    Press Ctrl+C to stop the app
echo.

flutter run --debug