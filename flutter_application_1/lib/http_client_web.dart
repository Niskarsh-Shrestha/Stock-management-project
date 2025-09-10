import 'package:http/browser_client.dart';

BrowserClient createHttpClient() {
  final c = BrowserClient()..withCredentials = true; // SEND COOKIES
  return c;
}