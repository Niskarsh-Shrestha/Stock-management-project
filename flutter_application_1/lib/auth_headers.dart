import 'session.dart';

class AuthHeaders {
  static Map<String, String> get value =>
      Session.sid == null ? {} : {'X-Session-Id': Session.sid!};
}