import 'package:http/browser_client.dart';

BrowserClient createHttpClient() {
  final c = BrowserClient()..withCredentials = true;
  return c;
}