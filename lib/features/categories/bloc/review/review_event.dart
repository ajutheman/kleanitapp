part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class LoadReviews extends ReviewEvent {
  final int secondCatId;

  const LoadReviews({required this.secondCatId});
}

class SubmitReview extends ReviewEvent {
  final int secondCatId;
  final String review;
  final int rating;

  const SubmitReview({required this.secondCatId, required this.review, required this.rating});
}

class ReviewSubmitted extends ReviewState {}
