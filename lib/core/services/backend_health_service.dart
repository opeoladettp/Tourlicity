import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_result.dart';
import '../config/environment_config.dart';

/// Service for checking backend health and connectivity
class BackendHealthService {
  BackendHealthService({required Dio dio}) : _dio = dio;

  final Dio _dio;
  
  // Create a separate Dio client for API endpoints that need /api/v1 prefix
  late final Dio _apiDio = Dio(BaseOptions(
    baseUrl: EnvironmentConfig.apiBaseUrl,
    connectTimeout: EnvironmentConfig.networkTimeout,
    receiveTimeout: EnvironmentConfig.networkTimeout,
    sendTimeout: EnvironmentConfig.networkTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Tourlicity-Flutter/${EnvironmentConfig.current.name}',
    },
  ));

  /// Check if backend is healthy and reachable
  Future<ApiResult<BackendHealthStatus>> checkHealth() async {
    try {
      debugPrint('BackendHealth: Checking backend health...');
      
      final response = await _dio.get('/health');
      
      // Accept both 200 (healthy) and 503 (unhealthy but responding) status codes
      if (response.statusCode == 200 || response.statusCode == 503) {
        final data = response.data;
        final status = BackendHealthStatus.fromJson(data);
        
        debugPrint('BackendHealth: Backend responded - ${status.status}');
        return ApiSuccess(data: status);
      } else {
        return ApiFailure(message: 'Backend health check failed with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle 503 as a valid response (unhealthy but responding)
      if (e.response?.statusCode == 503) {
        try {
          final data = e.response?.data;
          if (data != null) {
            final status = BackendHealthStatus.fromJson(data);
            debugPrint('BackendHealth: Backend responded but unhealthy - ${status.status}');
            return ApiSuccess(data: status);
          }
        } catch (parseError) {
          debugPrint('BackendHealth: Failed to parse 503 response: $parseError');
        }
      }
      
      final errorMessage = _handleDioError(e);
      debugPrint('BackendHealth: Health check failed - $errorMessage');
      return ApiFailure(message: errorMessage);
    } catch (e) {
      final errorMessage = 'Health check error: ${e.toString()}';
      debugPrint('BackendHealth: $errorMessage');
      return ApiFailure(message: errorMessage);
    }
  }

  /// Check detailed backend metrics
  Future<ApiResult<BackendMetrics>> checkMetrics() async {
    try {
      debugPrint('BackendHealth: Checking backend metrics...');
      
      final response = await _dio.get('/health/metrics');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final metrics = BackendMetrics.fromJson(data);
        
        debugPrint('BackendHealth: Metrics retrieved successfully');
        return ApiSuccess(data: metrics);
      } else {
        return ApiFailure(message: 'Backend metrics check failed with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      debugPrint('BackendHealth: Metrics check failed - $errorMessage');
      return ApiFailure(message: errorMessage);
    } catch (e) {
      final errorMessage = 'Metrics check error: ${e.toString()}';
      debugPrint('BackendHealth: $errorMessage');
      return ApiFailure(message: errorMessage);
    }
  }

  /// Validate API configuration
  Future<ApiResult<ConfigValidation>> validateConfig() async {
    try {
      debugPrint('BackendHealth: Validating API configuration...');
      
      final response = await _apiDio.post('/config/validate', data: {
        'baseUrl': EnvironmentConfig.apiBaseUrl,
        'environment': EnvironmentConfig.current.name,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final validation = ConfigValidation.fromJson(data);
        
        debugPrint('BackendHealth: Configuration validation completed');
        return ApiSuccess(data: validation);
      } else {
        return ApiFailure(message: 'Configuration validation failed with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      debugPrint('BackendHealth: Config validation failed - $errorMessage');
      return ApiFailure(message: errorMessage);
    } catch (e) {
      final errorMessage = 'Config validation error: ${e.toString()}';
      debugPrint('BackendHealth: $errorMessage');
      return ApiFailure(message: errorMessage);
    }
  }

  /// Handle Dio errors with proper error messages
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Backend connection timeout - server may be down';
      case DioExceptionType.sendTimeout:
        return 'Request timeout - backend is slow to respond';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout - backend is not responding';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 503:
            return 'Backend service unavailable';
          case 500:
            return 'Backend internal server error';
          default:
            return 'Backend error ($statusCode)';
        }
      case DioExceptionType.connectionError:
        return 'Cannot connect to backend - check if server is running at ${EnvironmentConfig.apiBaseUrl}';
      case DioExceptionType.cancel:
        return 'Health check was cancelled';
      case DioExceptionType.badCertificate:
        return 'Backend SSL certificate error';
      case DioExceptionType.unknown:
        return 'Backend connection error - ${e.message}';
    }
  }
}

/// Backend health status model
class BackendHealthStatus {
  const BackendHealthStatus({
    required this.status,
    required this.timestamp,
    required this.uptime,
    required this.environment,
    required this.version,
    required this.services,
  });

  final String status;
  final String timestamp;
  final double uptime;
  final String environment;
  final String version;
  final Map<String, ServiceStatus> services;

  factory BackendHealthStatus.fromJson(Map<String, dynamic> json) {
    final servicesData = json['services'] as Map<String, dynamic>? ?? {};
    final services = <String, ServiceStatus>{};
    
    for (final entry in servicesData.entries) {
      if (entry.value is Map<String, dynamic>) {
        services[entry.key] = ServiceStatus.fromJson(entry.value);
      }
    }

    return BackendHealthStatus(
      status: json['status'] ?? 'UNKNOWN',
      timestamp: json['timestamp'] ?? '',
      uptime: (json['uptime'] ?? 0).toDouble(),
      environment: json['environment'] ?? 'unknown',
      version: json['version'] ?? '0.0.0',
      services: services,
    );
  }

  bool get isHealthy => status.toUpperCase() == 'HEALTHY';
  
  List<String> get unhealthyServices {
    return services.entries
        .where((entry) => !entry.value.isHealthy)
        .map((entry) => entry.key)
        .toList();
  }
}

/// Service status model
class ServiceStatus {
  const ServiceStatus({
    required this.status,
    required this.message,
    required this.timestamp,
  });

  final String status;
  final String message;
  final String timestamp;

  factory ServiceStatus.fromJson(Map<String, dynamic> json) {
    return ServiceStatus(
      status: json['status'] ?? 'unknown',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  bool get isHealthy => status.toLowerCase() == 'healthy';
}

/// Backend metrics model
class BackendMetrics {
  const BackendMetrics({
    required this.timestamp,
    required this.system,
    required this.api,
  });

  final String timestamp;
  final SystemMetrics system;
  final ApiMetrics api;

  factory BackendMetrics.fromJson(Map<String, dynamic> json) {
    return BackendMetrics(
      timestamp: json['timestamp'] ?? '',
      system: SystemMetrics.fromJson(json['system'] ?? {}),
      api: ApiMetrics.fromJson(json['api'] ?? {}),
    );
  }
}

/// System metrics model
class SystemMetrics {
  const SystemMetrics({
    required this.memory,
    required this.cpu,
    required this.uptime,
  });

  final MemoryMetrics memory;
  final CpuMetrics cpu;
  final double uptime;

  factory SystemMetrics.fromJson(Map<String, dynamic> json) {
    return SystemMetrics(
      memory: MemoryMetrics.fromJson(json['memory'] ?? {}),
      cpu: CpuMetrics.fromJson(json['cpu'] ?? {}),
      uptime: (json['uptime'] ?? 0).toDouble(),
    );
  }
}

/// Memory metrics model
class MemoryMetrics {
  const MemoryMetrics({
    required this.rss,
    required this.heapTotal,
    required this.heapUsed,
    required this.heapUsagePercent,
  });

  final String rss;
  final String heapTotal;
  final String heapUsed;
  final String heapUsagePercent;

  factory MemoryMetrics.fromJson(Map<String, dynamic> json) {
    return MemoryMetrics(
      rss: _formatBytes(json['rss']),
      heapTotal: _formatBytes(json['heapTotal']),
      heapUsed: _formatBytes(json['heapUsed']),
      heapUsagePercent: '${(json['heapUsagePercent'] ?? 0).toStringAsFixed(1)}%',
    );
  }

  static String _formatBytes(dynamic bytes) {
    if (bytes == null) return '0MB';
    final value = bytes is int ? bytes : int.tryParse(bytes.toString()) ?? 0;
    return '${(value / 1024 / 1024).toStringAsFixed(1)}MB';
  }
}

/// CPU metrics model
class CpuMetrics {
  const CpuMetrics({
    required this.loadAverage,
    required this.usage,
  });

  final List<double> loadAverage;
  final String usage;

  factory CpuMetrics.fromJson(Map<String, dynamic> json) {
    return CpuMetrics(
      loadAverage: List<double>.from(json['loadAverage'] ?? [0.0, 0.0, 0.0]),
      usage: '${(json['usage'] ?? 0).toStringAsFixed(2)}%',
    );
  }
}

/// API metrics model
class ApiMetrics {
  const ApiMetrics({
    required this.requests,
    required this.response,
  });

  final RequestMetrics requests;
  final ResponseMetrics response;

  factory ApiMetrics.fromJson(Map<String, dynamic> json) {
    return ApiMetrics(
      requests: RequestMetrics.fromJson(json['requests'] ?? {}),
      response: ResponseMetrics.fromJson(json['response'] ?? {}),
    );
  }
}

/// Request metrics model
class RequestMetrics {
  const RequestMetrics({
    required this.total,
    required this.successful,
    required this.failed,
  });

  final int total;
  final int successful;
  final int failed;

  factory RequestMetrics.fromJson(Map<String, dynamic> json) {
    return RequestMetrics(
      total: json['total'] ?? 0,
      successful: json['successful'] ?? 0,
      failed: json['failed'] ?? 0,
    );
  }

  double get successRate => total > 0 ? (successful / total) * 100 : 0.0;
}

/// Response metrics model
class ResponseMetrics {
  const ResponseMetrics({
    required this.averageTime,
    required this.p95Time,
    required this.p99Time,
  });

  final String averageTime;
  final String p95Time;
  final String p99Time;

  factory ResponseMetrics.fromJson(Map<String, dynamic> json) {
    return ResponseMetrics(
      averageTime: _formatTime(json['averageTime']),
      p95Time: _formatTime(json['p95Time']),
      p99Time: _formatTime(json['p99Time']),
    );
  }

  static String _formatTime(dynamic time) {
    if (time == null) return '0ms';
    final value = time is num ? time : num.tryParse(time.toString()) ?? 0;
    return '${value.toStringAsFixed(2)}ms';
  }
}

/// Configuration validation model
class ConfigValidation {
  const ConfigValidation({
    required this.isValid,
    required this.warnings,
    required this.suggestions,
  });

  final bool isValid;
  final List<String> warnings;
  final List<String> suggestions;

  factory ConfigValidation.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json; // Handle wrapped response
    return ConfigValidation(
      isValid: data['isValid'] ?? false,
      warnings: List<String>.from(data['warnings'] ?? []),
      suggestions: List<String>.from(data['suggestions'] ?? []),
    );
  }
}