import 'package:equatable/equatable.dart';
import 'package:home_management/features/expense/domain/entities/expense_entity.dart';

class BudgetSummaryEntity extends Equatable {
  final String id;
  final String familyId;
  final int month;
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final double fixedExpenses;
  final double remainingBudget;
  final Map<ExpenseCategory, double> expensesByCategory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetSummaryEntity({
    required this.id,
    required this.familyId,
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpenses,
    required this.fixedExpenses,
    required this.remainingBudget,
    required this.expensesByCategory,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalVariableExpenses => totalExpenses - fixedExpenses;

  double getCategoryPercentage(ExpenseCategory category) {
    if (totalExpenses == 0) return 0;
    return (expensesByCategory[category] ?? 0) / totalExpenses * 100;
  }

  @override
  List<Object?> get props => [
        id,
        familyId,
        month,
        year,
        totalIncome,
        totalExpenses,
        fixedExpenses,
        remainingBudget,
        expensesByCategory,
        createdAt,
        updatedAt,
      ];
}