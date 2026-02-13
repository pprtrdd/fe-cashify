import 'package:cashify/core/app_config/domain/entities/app_config_entity.dart';
import 'package:cashify/core/app_config/domain/repositories/app_config_repository.dart';

class AppConfigUsecases {
  final AppConfigRepository repository;

  AppConfigUsecases({required this.repository});

  Future<AppConfigEntity> get() {
    return repository.getAppConfig();
  }
}
