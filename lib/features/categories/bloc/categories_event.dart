part of 'categories_bloc.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

// class LoadCategories extends CategoriesEvent {
//  // String type
// }
class LoadCategories extends CategoriesEvent {
  final String type; // 👈 added type

  const LoadCategories({required this.type});

  @override
  List<Object?> get props => [type];
}
