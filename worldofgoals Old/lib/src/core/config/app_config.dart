class AppConfig {
  static const String appName = 'GoalQuest';
  static const String appVersion = '1.0.0';
  
  // Database Configuration
  static const String dbName = 'goalquest.db';
  static const int dbVersion = 1;
  
  // XP Configuration
  static const int xpEasyTask = 50;
  static const int xpMediumTask = 100;
  static const int xpHardTask = 200;
  static const int xpPerLevel = 1000;
  static const int maxLevel = 10;
  
  // Achievement Thresholds
  static const int tasksForAchievement = 10;
  static const int daysStreakForAchievement = 3;
  static const int levelForAchievement = 5;
  
  // Storage Keys
  static const String userPrefsKey = 'user_prefs';
  static const String authTokenKey = 'auth_token';
  static const String themeKey = 'app_theme';
  
  // Feature Flags
  static const bool enableBiometrics = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
}
