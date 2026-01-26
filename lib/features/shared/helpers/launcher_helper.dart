import 'package:url_launcher/url_launcher.dart';

class LauncherHelper {
  static Future<void> openUrl(String url) async {
    if (url.isEmpty) return;

    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      rethrow;
    }
  }
}
