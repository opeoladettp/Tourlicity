#!/bin/bash

# API Integration Test Script
echo "🚀 Testing Tourlicity App API Integration"
echo "========================================="

# Check if backend is running
echo "📡 Checking backend API availability..."
if curl -s http://localhost:3000/api/v1/health > /dev/null 2>&1; then
    echo "✅ Backend API is running at http://localhost:3000/api/v1"
else
    echo "❌ Backend API is not accessible at http://localhost:3000/api/v1"
    echo "   Please ensure your backend server is running"
    exit 1
fi

# Run Flutter app in debug mode
echo ""
echo "🏃 Starting Flutter app..."
echo "   The app is configured to use http://localhost:3000/api/v1"
echo "   Press Ctrl+C to stop the app"
echo ""

flutter run --debug