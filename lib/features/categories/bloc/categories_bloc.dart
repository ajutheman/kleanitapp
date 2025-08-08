import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../modle/category_model.dart';
import '../respository/category_repository.dart';

// import 'main_category_model.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryRepository categoryRepository;

  CategoriesBloc({required this.categoryRepository})
      : super(CategoriesInitial()) {
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<CategoriesState> emit) async {
    emit(CategoriesLoading());
    try {
      final categories = await categoryRepository.fetchCategories(event.type);
      emit(CategoriesLoaded(categories: categories));
    } catch (e) {
      emit(CategoriesError(error: e.toString()));
    }
  }
}
