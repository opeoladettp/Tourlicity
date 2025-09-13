enum Environment { development, staging, production }

class AppConfig {
  static Environment _environment = Environment.development;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://localhost:3000/api/v1';
      case Environment.staging:
        return 'https://staging-api.tourlicity.com/api/v1';
      case Environment.production:
        return 'https://api.tourlicity.com/api/v1';
    }
  }

  static bool get isDebug => _environment != Environment.production;

  static String get environmentName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }
}
