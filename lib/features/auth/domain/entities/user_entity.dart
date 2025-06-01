import 'package:equatable/equatable.dart';

enum UserRole { admin, user }

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final String? familyId;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.familyId,
  });

  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [id, name, email, role, createdAt, familyId];
}