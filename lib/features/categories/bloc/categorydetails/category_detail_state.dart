part of 'category_detail_bloc.dart';

abstract class CategoryDetailState extends Equatable {
  const CategoryDetailState();

  @override
  List<Object?> get props => [];
}

class CategoryDetailInitial extends CategoryDetailState {}

class CategoryDetailLoading extends CategoryDetailState {}

class CategoryDetailLoaded extends CategoryDetailState {
  final CategoryDetail detail;

  const CategoryDetailLoaded({required this.detail});

  @override
  List<Object?> get props => [detail];
}

class CategoryDetailError extends CategoryDetailState {
  final String error;

  const CategoryDetailError({required this.error});

  @override
  List<Object?> get props => [error];
}
