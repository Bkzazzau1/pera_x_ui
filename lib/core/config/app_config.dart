class AppConfig {
  static const String appName = 'Pera-X';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  static const Duration apiTimeout = Duration(seconds: 30);

  static const bool enableMockMode = bool.fromEnvironment(
    'ENABLE_MOCK_MODE',
    defaultValue: false,
  );

  static const bool enableAdminPanel = bool.fromEnvironment(
    'ENABLE_ADMIN_PANEL',
    defaultValue: false,
  );
}
