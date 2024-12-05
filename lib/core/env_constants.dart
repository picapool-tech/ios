import 'package:picapool/core/env.dart';

class APIConstants {
  static String get apiUrl => Env.get('API_URL');
  static String get googleClientId => Env.get('GOOGLE_CLIENT_ID');
  static String get backendSocketIp => Env.get('backendSocketIp');
  static String get googleApiKey => Env.get('GOOGLE_API_KEY');
  static String get googleApiKeyIos => Env.get('GOOGLE_API_KEY_IOS');
  static String get msg91AuthKey => Env.get('MSG91_AUTH_KEY');
  static String get googleClientIdIos => Env.get('GOOGLE_CLIENT_ID_IOS');
  static String get backendIp => Env.get('backendIp');
  static String get vendorIp => Env.get('vendorIp');
}
