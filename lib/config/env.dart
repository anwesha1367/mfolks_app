class EnvConfig {
  EnvConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.3:5000/api',
  );

  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'dh0xkp07q',
  );

  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '117248309973-pfgi9n3gf7j18k6kj321vl9efc68d5ga.apps.googleusercontent.com',
  );

  static const String appleClientId = String.fromEnvironment(
    'APPLE_CLIENT_ID',
    defaultValue: 'your-apple-client-idye',
  );

  static const String metalsDevApiKey = String.fromEnvironment(
    'METALS_DEV_API_KEY',
    defaultValue: 'RDPVLLKXQ1VUPNMDALLF940MDALLF',
  );
}


