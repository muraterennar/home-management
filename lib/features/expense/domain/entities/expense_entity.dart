import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  food,
  transportation,
  entertainment,
  health,
  education,
  shopping,
  bills,
  other, groceries, utilities, rent, healthcare, clothing,
}

class ExpenseEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String createdByUserId;
  final String familyId;
  final String? description;
  final List<String>? tags;
  final String? receiptImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdByUserId,
    required this.familyId,
    this.description,
    this.tags,
    this.receiptImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        category,
        date,
        createdByUserId,
        familyId,
        description,
        tags,
        receiptImageUrl,
        createdAt,
        updatedAt,
      ];
}