import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final bool isExpense;
  final bool isExtra;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.isExpense,
    required this.isExtra,
    required this.createdAt,
    required this.updatedAt,
    required this.isArchived,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    isExpense,
    isExtra,
    createdAt,
    updatedAt,
    isArchived,
  ];

  CategoryEntity copyWith({
    String? id,
    String? name,
    bool? isExpense,
    bool? isExtra,
    bool? isArchived,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isExpense: isExpense ?? this.isExpense,
      isExtra: isExtra ?? this.isExtra,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
