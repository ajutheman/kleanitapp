// // lib/logic/blocs/search/search_bloc.dart
// import 'package:bloc/bloc.dart';
//
// import 'search_event.dart';
// import 'search_state.dart';
//
// class SearchBloc extends Bloc<SearchEvent, SearchState> {
//   final SearchRepository searchRepository;
//
//   SearchBloc({required this.searchRepository}) : super(SearchInitial()) {
//     on<SearchQueryChanged>(_onSearchQueryChanged);
//     on<SearchSubmitted>(_onSearchSubmitted);
//   }
//
//   Future<void> _onSearchQueryChanged(
//     SearchQueryChanged event,
//     Emitter<SearchState> emit,
//   ) async {
//     if (event.query.isEmpty) {
//       emit(SearchInitial());
//       return;
//     }
//     emit(SearchLoading());
//     try {
//       final results = await searchRepository.searchServices(event.query);
//       emit(SearchLoaded(results: results));
//     } catch (error) {
//       emit(SearchError(error: error.toString()));
//     }
//   }
//
//   Future<void> _onSearchSubmitted(
//     SearchSubmitted event,
//     Emitter<SearchState> emit,
//   ) async {
//     // Optionally, you can use a similar logic as _onSearchQueryChanged,
//     // or combine both into one event.
//     if (event.query.isEmpty) {
//       emit(SearchInitial());
//       return;
//     }
//     emit(SearchLoading());
//     try {
//       final results = await searchRepository.searchServices(event.query);
//       emit(SearchLoaded(results: results));
//     } catch (error) {
//       emit(SearchError(error: error.toString()));
//     }
//   }
// }
