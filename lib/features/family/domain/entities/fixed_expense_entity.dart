import 'package:equatable/equatable.dart';

class FixedExpenseEntity extends Equatable {
  final String id;
  final String name;
  final double amount;
  final DateTime paymentDay;
  final String familyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FixedExpenseEntity({
    required this.id,
    required this.name,
    required this.amount,
    required this.familyId,
    required this.createdAt,
    required this.updatedAt,
    required this.paymentDay,
  });

  @override
  List<Object?> get props => [id, name, amount, familyId, createdAt, updatedAt];
}