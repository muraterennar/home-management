import 'package:equatable/equatable.dart';
import 'package:home_management/core/utils/mappable.dart';

enum UserRole { admin, user }

class UserEntity extends Equatable implements Mappable {
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

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'familyId': familyId,
      'isAdmin': isAdmin ? 'true' : 'false',
    };
  }


  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.user,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      familyId: map['familyId'] as String?,
    );
  }
}

