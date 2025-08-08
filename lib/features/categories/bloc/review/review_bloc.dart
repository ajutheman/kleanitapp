import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kleanit/features/categories/respository/review_repository.dart'
    show ReviewRepository;

import '../../modle/review_model.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repository;

  ReviewBloc({required this.repository}) : super(ReviewInitial()) {
    on<LoadReviews>((event, emit) async {
      emit(ReviewLoading());
      try {
        final reviewResponse =
            await repository.fetchReviews(id: event.secondCatId);
        emit(ReviewLoaded(reviews: reviewResponse.data));
      } catch (e) {
        emit(ReviewError(message: e.toString()));
      }
    });
    on<SubmitReview>((event, emit) async {
      try {
        final success = await repository.submitReview(
          id: event.secondCatId,
          review: event.review,
          rating: event.rating,
        );
        if (success) {
          emit(ReviewSubmitted());
        } else {
          emit(ReviewError(message: 'Failed to submit review'));
        }
      } catch (e) {
        emit(ReviewError(message: e.toString()));
      }
    });
  }
}
