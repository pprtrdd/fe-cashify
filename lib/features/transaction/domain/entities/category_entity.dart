class CategoryEntity {
  final String id;
  final String userId;
  final String name;
  final bool isExpense;
  final bool isSystem;

  CategoryEntity({
    required this.id, 
    required this.userId, 
    required this.name, 
    required this.isExpense,
    this.isSystem = false,
  });
}