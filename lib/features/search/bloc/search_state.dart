// // lib/logic/blocs/search/search_state.dart
// import 'package:equatable/equatable.dart';
// // Assume you have a SearchResultModel defined in your models.
// import 'package:your_app/data/models/search_result_model.dart';
//
// abstract class SearchState extends Equatable {
//   const SearchState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class SearchInitial extends SearchState {}
//
// class SearchLoading extends SearchState {}
//
// class SearchLoaded extends SearchState {
//   final List<SearchResultModel> results;
//
//   const SearchLoaded({required this.results});
//
//   @override
//   List<Object?> get props => [results];
// }
//
// class SearchError extends SearchState {
//   final String error;
//
//   const SearchError({required this.error});
//
//   @override
//   List<Object?> get props => [error];
// }
