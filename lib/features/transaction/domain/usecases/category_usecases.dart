import 'package:cashify/features/transaction/domain/entities/category_entity.dart';
import 'package:cashify/features/transaction/domain/repositories/category_repository.dart';

class CategoryUsecases {
  final CategoryRepository categoryRepository;

  CategoryUsecases({required this.categoryRepository});

  Future<List<CategoryEntity>> fetchAll() async {
    return categoryRepository.fetchCategories();
  }
}
