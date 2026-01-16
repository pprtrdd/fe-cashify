import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/domain/repositories/category_repository.dart';

class CategoryUsecases {
  final CategoryRepository repository;

  CategoryUsecases({required this.repository});

  Future<List<CategoryEntity>> fetchAll() async {
    return repository.fetchCategories();
  }
}
