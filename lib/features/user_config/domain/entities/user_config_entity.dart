import 'package:equatable/equatable.dart';

class UserConfigEntity extends Equatable {
  final bool setupCompleted;
  final String uid;
  final DateTime createdAt;

  const UserConfigEntity({required this.setupCompleted, required this.uid, required this.createdAt});

  @override
  List<Object?> get props => [setupCompleted, uid, createdAt];
}
