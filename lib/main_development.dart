import 'core/config/app_config.dart';
import 'main.dart' as app;

void main() {
  AppConfig.setEnvironment(Environment.development);
  app.main();
}
