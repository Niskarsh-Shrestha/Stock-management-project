class Env {
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://stock-management-project-production.up.railway.app',
  );
}
