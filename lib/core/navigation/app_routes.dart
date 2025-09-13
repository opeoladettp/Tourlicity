/// Application route constants
class AppRoutes {
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

  // Main routes
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String splash = '/splash';

  // Dashboard routes (for backward compatibility with tests)
  static const String systemAdminDashboard = '/admin/dashboard';
  static const String providerAdminDashboard = '/provider/dashboard';
  static const String touristDashboard = '/tourist/dashboard';

  // Profile routes
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String profileCompletion = '/profile/completion';

  // Tour template routes
  static const String tourTemplates = '/tour-templates';
  static const String tourTemplateCreate = '/tour-templates/create';
  static const String tourTemplateEdit = '/tour-templates/edit';
  static const String tourTemplateManagement = '/tour-templates/management';

  // Provider routes
  static const String providers = '/providers';
  static const String providerCreate = '/providers/create';
  static const String providerEdit = '/providers/edit';

  // Admin routes
  static const String adminDashboard = '/admin';
  static const String userManagement = '/admin/users';
  static const String providerManagement = '/admin/providers';
  static const String analytics = '/admin/analytics';
  static const String registrationManagement = '/admin/registrations';

  // Tourist routes (for backward compatibility with tests)
  static const String joinTour = '/tours/join';
  static const String myTours = '/tours/my';
  static const String tourDetails = '/tours/details';
  static const String customTourManagement = '/tours/custom';

  // Common routes (for backward compatibility with tests)
  static const String documents = '/documents';
  static const String messages = '/messages';
}
