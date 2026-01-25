import 'package:cashify/features/configuration/domain/entities/user_settings_entity.dart';
import 'package:cashify/features/configuration/domain/repositories/settings_repository.dart';

class SettingsUsecases {
  final SettingsRepository repository;

  SettingsUsecases({required this.repository});

  Future<UserSettingsEntity> get() => repository.getSettings();
  Future<void> save(UserSettingsEntity settings) =>
      repository.saveSettings(settings);
}
