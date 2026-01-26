import 'package:cashify/core/app_info/domain/entities/app_info_entity.dart';
import 'package:cashify/core/app_info/domain/repositories/app_info_repository.dart';

class AppInfoUsecases {
  final AppInfoRepository repository;

  AppInfoUsecases({required this.repository});

  Future<AppInfoEntity> get() {
    final data = repository.getAppInfo();

    return data;
  }
}
