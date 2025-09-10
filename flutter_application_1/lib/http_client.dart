import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/browser_client.dart' show BrowserClient;

http.Client createHttpClient() {
  if (kIsWeb) {
    // ignore: avoid_web_libraries_in_flutter
    final c = BrowserClient()..withCredentials = true;
    return c;
  }
  return http.Client();
}