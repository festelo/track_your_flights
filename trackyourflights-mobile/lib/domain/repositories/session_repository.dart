abstract class SessionRepository {
  bool get authorized;
  Future<void> authenticate(String username, String password);
  Future<void> verify();
}
