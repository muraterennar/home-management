import 'package:equatable/equatable.dart';
import 'package:home_management/features/auth/domain/entities/user_entity.dart';
import 'package:home_management/features/family/domain/entities/fixed_expense_entity.dart';

class FamilyEntity extends Equatable {
  final String id;
  final String name;
  final double monthlyIncome;
  final List<FixedExpenseEntity> fixedExpenses;
  final List<UserEntity> members;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyEntity({
    required this.id,
    required this.name,
    required this.monthlyIncome,
    required this.fixedExpenses,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalFixedExpenses => fixedExpenses.fold(
        0,
        (previousValue, expense) => previousValue + expense.amount,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        monthlyIncome,
        fixedExpenses,
        members,
        createdAt,
        updatedAt,
      ];
}