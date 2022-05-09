import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  final BehaviorSubject<String?> _tokenSubject = BehaviorSubject.seeded(null);

  ValueStream<String?> get currentToken => _tokenSubject.stream;

  void setCurrentToken(String? tokenInfo) {
    _tokenSubject.add(tokenInfo);
    _saveToken(tokenInfo);
  }

  Future<bool> restoreToken() async {
    final instance = await SharedPreferences.getInstance();
    final accessToken = instance.getString('access_token');
    if (accessToken != null) {
      setCurrentToken(accessToken);
      return true;
    }
    return false;
  }

  Future<void> _saveToken(String? token) async {
    final instance = await SharedPreferences.getInstance();
    if (token == null) {
      instance.remove('access_token');
    } else {
      await instance.setString('access_token', token);
    }
  }

  void logOut() {
    setCurrentToken(null);
  }
}
