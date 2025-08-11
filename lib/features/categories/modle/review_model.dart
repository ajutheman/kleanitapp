class ReviewResponse {
  final int currentPage;
  final List<Review> data;
  final int total;

  // Additional pagination fields can be added if needed.

  ReviewResponse({required this.currentPage, required this.data, required this.total});

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(currentPage: json['current_page'], data: (json['data'] as List).map((e) => Review.fromJson(e as Map<String, dynamic>)).toList(), total: json['total']);
  }
}

class Review {
  final int id;
  final int customerId;
  final int secondCategoryId;
  final String review;
  final int rating;
  final String createdAt;
  final String updatedAt;
  final Customer customer; // Now include customer details

  Review({
    required this.id,
    required this.customerId,
    required this.secondCategoryId,
    required this.review,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.customer,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      customerId: json['customer_id'],
      secondCategoryId: json['second_category_id'],
      review: json['review'],
      rating: json['rating'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String email;

  Customer({required this.id, required this.name, required this.email});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(id: json['id'], name: json['name'], email: json['email']);
  }
}
