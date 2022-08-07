import 'package:trackyourflights/domain/repositories/session_repository.dart';

class SessionRepositoryMock implements SessionRepository {
  @override
  Future<void> authenticate(String username, String password) => Future.value();

  @override
  bool get authorized => true;

  @override
  Future<void> verify() => Future.value();
}
