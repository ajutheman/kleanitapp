import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../modle/Appcategory_detail_model.dart';
import '../../respository/Appcategory_detail_repository.dart';

part 'category_detail_event.dart';
part 'category_detail_state.dart';

class CategoryDetailBloc extends Bloc<CategoryDetailEvent, CategoryDetailState> {
  final AppCategoryDetailRepository repository;
  final int mainCategoryId;
  final String type;

  CategoryDetailBloc({required this.repository, required this.mainCategoryId, required this.type}) : super(CategoryDetailInitial()) {
    on<LoadCategoryDetail>(_onLoadCategoryDetail);
  }

  Future<void> _onLoadCategoryDetail(LoadCategoryDetail event, Emitter<CategoryDetailState> emit) async {
    emit(CategoryDetailLoading());
    try {
      final detailResponse = await repository.fetchCategoryDetails(mainCategoryId, type);
      emit(CategoryDetailLoaded(detail: detailResponse.data));
    } catch (e) {
      emit(CategoryDetailError(error: e.toString()));
    }
  }
}
