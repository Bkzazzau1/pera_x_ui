class AppConfig {
  static const String appName = 'Pera-X';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.pera-x.demo',
  );

  static const Duration apiTimeout = Duration(seconds: 30);

  static const bool enableMockMode = bool.fromEnvironment(
    'ENABLE_MOCK_MODE',
    defaultValue: true,
  );
}
