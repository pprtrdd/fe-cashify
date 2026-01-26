import 'package:cashify/features/user_config/domain/repositories/user_config_repository.dart';

class UserConfigUsecases {
  final UserConfigRepository repository;

  UserConfigUsecases({required this.repository});

  Future<void> initializeUserDataIfNew(String uid) async {
    final isInitialized = await repository.isUserInitialized(uid);

    if (!isInitialized) {
      await repository.initializeUserData(uid);
    }
  }

  Future<bool> isUserInitialized(String uid) async {
    return repository.isUserInitialized(uid);
  }
}
