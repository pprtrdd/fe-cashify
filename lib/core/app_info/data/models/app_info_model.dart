import 'package:cashify/core/app_info/domain/entities/app_info_entity.dart';

class AppInfoModel extends AppInfoEntity {
  const AppInfoModel({
    required super.appName,
    required super.author,
    required super.description,
    required super.githubProfile,
    required super.linkedinProfile,
    required super.supportEmail,
    required super.lastYearDeploy,
  });

  factory AppInfoModel.fromFirestore(Map<String, dynamic> json) {
    return AppInfoModel(
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
