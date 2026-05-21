class ApiConfig {
  // Android emulator reaches the host machine at 10.0.2.2.
  // Physical device: replace with your LAN IP, e.g. http://192.168.1.x:3000
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Web-client OAuth ID (same value as backend GOOGLE_CLIENT_ID .env var)
  static const String googleClientId =
      'YOUR_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com';
}
