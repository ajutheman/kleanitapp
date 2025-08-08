part of 'category_detail_bloc.dart';

abstract class CategoryDetailEvent extends Equatable {
  const CategoryDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoryDetail extends CategoryDetailEvent {}
