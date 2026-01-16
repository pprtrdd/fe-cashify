import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final bool isExpense;
  final bool isExtra;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.isExpense,
    required this.isExtra,
  });

  @override
  List<Object?> get props => [id, name, isExpense, isExtra];

  CategoryEntity copyWith({
    String? id,
    String? name,
    bool? isExpense,
    bool? isExtra,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isExpense: isExpense ?? this.isExpense,
      isExtra: isExtra ?? this.isExtra,
    );
  }
}
