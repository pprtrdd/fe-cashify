import 'package:cashify/core/app_config/domain/entities/app_config_entity.dart';

class AppConfigModel extends AppConfigEntity {
  const AppConfigModel({
    required super.appName,
    required super.author,
    required super.description,
    required super.githubProfile,
    required super.linkedinProfile,
    required super.supportEmail,
    required super.lastYearDeploy,
  });

  factory AppConfigModel.fromFirestore(Map<String, dynamic> json) {
    return AppConfigModel(
      appName: json['appName'].toString(),
      author: json['author'].toString(),
      description: json['description'].toString(),
      githubProfile: json['githubProfile'].toString(),
      linkedinProfile: json['linkedinProfile'].toString(),
      supportEmail: json['supportEmail'].toString(),
      lastYearDeploy: json['lastYearDeploy'].toString(),
    );
  }
}
