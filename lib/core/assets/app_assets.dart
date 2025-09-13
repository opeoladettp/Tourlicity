/// App assets constants and management
class AppAssets {
  static const String _imagesPath = 'assets/images/';
  static const String _iconsPath = 'assets/icons/';
  static const String _fontsPath = 'assets/fonts/';

  // App Icons
  static const String appIcon = '${_imagesPath}app_icon.png';
  static const String splashLogo = '${_imagesPath}splash_logo.png';
  
  // Navigation Icons
  static const String homeIcon = '${_iconsPath}home.png';
  static const String toursIcon = '${_iconsPath}tours.png';
  static const String profileIcon = '${_iconsPath}profile.png';
  static const String messagesIcon = '${_iconsPath}messages.png';
  
  // Feature Icons
  static const String documentIcon = '${_iconsPath}document.png';
  static const String uploadIcon = '${_iconsPath}upload.png';
  static const String downloadIcon = '${_iconsPath}download.png';
  static const String joinTourIcon = '${_iconsPath}join_tour.png';
  
  // Status Icons
  static const String successIcon = '${_iconsPath}success.png';
  static const String errorIcon = '${_iconsPath}error.png';
  static const String warningIcon = '${_iconsPath}warning.png';
  static const String infoIcon = '${_iconsPath}info.png';
  
  // Fonts
  static const String robotoRegular = '${_fontsPath}Roboto-Regular.ttf';
  static const String robotoBold = '${_fontsPath}Roboto-Bold.ttf';

  /// Preload critical assets for better performance
  static List<String> get criticalAssets => [
    appIcon,
    splashLogo,
    robotoRegular,
    robotoBold,
  ];

  /// Get all app assets for validation
  static List<String> get allAssets => [
    ...criticalAssets,
    homeIcon,
    toursIcon,
    profileIcon,
    messagesIcon,
    documentIcon,
    uploadIcon,
    downloadIcon,
    joinTourIcon,
    successIcon,
    errorIcon,
    warningIcon,
    infoIcon,
  ];
}