import 'package:package_info_plus/package_info_plus.dart';

class AppConfigService {
  static Future<Map<String, String>> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    return {
      'appName': packageInfo.appName,
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'packageName': packageInfo.packageName,
    };
  }
}
