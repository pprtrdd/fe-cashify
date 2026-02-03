import 'package:equatable/equatable.dart';

class AppConfigEntity extends Equatable {
  final String appName;
  final String author;
  final String description;
  final String githubProfile;
  final String linkedinProfile;
  final String supportEmail;
  final String lastYearDeploy;

  const AppConfigEntity({
    required this.appName,
    required this.author,
    required this.description,
    required this.githubProfile,
    required this.linkedinProfile,
    required this.supportEmail,
    required this.lastYearDeploy,
  });

  @override
  List<Object?> get props => [
    appName,
    author,
    description,
    githubProfile,
    linkedinProfile,
    supportEmail,
    lastYearDeploy,
  ];

  static AppConfigEntity empty() {
    return const AppConfigEntity(
      appName: '',
      author: '',
      description: '',
      githubProfile: '',
      linkedinProfile: '',
      supportEmail: '',
      lastYearDeploy: '',
    );
  }
}
