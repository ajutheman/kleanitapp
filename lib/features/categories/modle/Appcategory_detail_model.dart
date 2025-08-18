import 'dart:convert';

class AppCategoryDetailResponse {
  final bool success;
  final String message;
  final CategoryDetail data;

  AppCategoryDetailResponse({required this.success, required this.message, required this.data});

  factory AppCategoryDetailResponse.fromJson(Map<String, dynamic> json) {
    return AppCategoryDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json.containsKey('data') && json['data'] != null ? CategoryDetail.fromJson(json['data']) : CategoryDetail.empty(),
    );
  }
}

class CategoryDetail {
  final int id;
  final String name;
  final String status;
  final String image;
  final List<FirstCategory> firstCategories;

  CategoryDetail({required this.id, required this.name, required this.status, required this.image, required this.firstCategories});

  factory CategoryDetail.fromJson(Map<String, dynamic> json) {
    return CategoryDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      image: json['image'] ?? '',
      firstCategories: json['first_categories'] != null ? List<FirstCategory>.from((json['first_categories'] as List).map((x) => FirstCategory.fromJson(x))) : [],
    );
  }

  factory CategoryDetail.empty() {
    return CategoryDetail(id: 0, name: '', status: '', image: '', firstCategories: []);
  }
}

class FirstCategory {
  final int id;
  final String name;
  final String status;
  final String image;
  final List<SecondCategory> secondCategories;

  FirstCategory({required this.id, required this.name, required this.status, required this.image, required this.secondCategories});

  factory FirstCategory.fromJson(Map<String, dynamic> json) {
    return FirstCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      image: json['image'] ?? '',
      secondCategories: json['second_categories'] != null ? List<SecondCategory>.from((json['second_categories'] as List).map((x) => SecondCategory.fromJson(x))) : [],
    );
  }
}

class SecondCategory {
  final int id;
  final String name;
  final String status;
  final String image;
  final List<ThirdCategory> thirdCategories;
  final String encryptedId;

  SecondCategory({required this.id, required this.name, required this.status, required this.image, required this.thirdCategories, required this.encryptedId});

  factory SecondCategory.fromJson(Map<String, dynamic> json) {
    return SecondCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      image: json['image'] ?? '',
      thirdCategories: json['third_categories'] != null ? List<ThirdCategory>.from((json['third_categories'] as List).map((x) => ThirdCategory.fromJson(x))) : [],
      encryptedId: json['encrypted_id'] ?? '',
    );
  }
}

// class ThirdCategory {
//   final int id;
//   final String name;
//   final String status;
//   final String type;
//   final String image;
//   final String price;
//   final String? oneInWeekPrice;
//   final String? twoInWeekPrice;
//   final String? threeInWeekPrice;
//   final String? fourInWeekPrice;
//   final String? fiveInWeekPrice;
//   final String? sixInWeekPrice;
//   final String extraHrPrice;
//   final String walletCoins;
//   final Map<String, dynamic>? schedule;
//   final List<MaterialItem> materials;
//
//   ThirdCategory({
//     required this.id,
//     required this.name,
//     required this.status,
//     required this.type,
//     required this.image,
//     required this.price,
//     this.oneInWeekPrice,
//     this.twoInWeekPrice,
//     this.threeInWeekPrice,
//     this.fourInWeekPrice,
//     this.fiveInWeekPrice,
//     this.sixInWeekPrice,
//     required this.extraHrPrice,
//     required this.walletCoins,
//     this.schedule,
//     required this.materials,
//   });
//
//   factory ThirdCategory.fromJson(Map<String, dynamic> json) {
//     Map<String, dynamic>? scheduleMap;
//     if (json['schedule'] != null &&
//         json['schedule'] is String &&
//         (json['schedule'] as String).isNotEmpty) {
//       try {
//         scheduleMap = jsonDecode(json['schedule']);
//       } catch (_) {
//         scheduleMap = {};
//       }
//     }
//     return ThirdCategory(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       status: json['status'] ?? '',
//       type: json['type'] ?? '',
//       image: json['image'] ?? '',
//       price: json['price']?.toString() ?? '',
//       oneInWeekPrice: json['one_in_week_price']?.toString(),
//       twoInWeekPrice: json['two_in_week_price']?.toString(),
//       threeInWeekPrice: json['three_in_week_price']?.toString(),
//       fourInWeekPrice: json['four_in_week_price']?.toString(),
//       fiveInWeekPrice: json['five_in_week_price']?.toString(),
//       sixInWeekPrice: json['six_in_week_price']?.toString(),
//       extraHrPrice: json['extra_hr_price']?.toString() ?? '',
//       walletCoins: json['wallet_coins']?.toString() ?? '',
//       schedule: scheduleMap,
//       materials: json['materials'] != null
//           ? List<MaterialItem>.from(
//               (json['materials'] as List).map((x) => MaterialItem.fromJson(x)))
//           : [],
//     );
//   }
// }

class ThirdCategory {
  final int id;
  final String name;
  final String status;
  final String type;
  final String image;
  final String price;
  final String? oneInWeekPrice;
  final String? twoInWeekPrice;
  final String? threeInWeekPrice;
  final String? fourInWeekPrice;
  final String? fiveInWeekPrice;
  final String? sixInWeekPrice;
  final String? onceInMonthPrice;
  final String? twiceInMonthPrice;
  final String? thriceInMonthPrice;
  final String extraHrPrice;
  final String walletCoins;
  final Map<String, dynamic>? schedule;
  final List<MaterialItem> materials;

  ThirdCategory({
    required this.id,
    required this.name,
    required this.status,
    required this.type,
    required this.image,
    required this.price,
    this.oneInWeekPrice,
    this.twoInWeekPrice,
    this.threeInWeekPrice,
    this.fourInWeekPrice,
    this.fiveInWeekPrice,
    this.sixInWeekPrice,
    this.onceInMonthPrice,
    this.twiceInMonthPrice,
    this.thriceInMonthPrice,
    required this.extraHrPrice,
    required this.walletCoins,
    this.schedule,
    required this.materials,
  });

  factory ThirdCategory.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? scheduleMap;
    if (json['schedule'] != null && json['schedule'] is String && (json['schedule'] as String).isNotEmpty) {
      try {
        scheduleMap = jsonDecode(json['schedule']);
      } catch (_) {
        scheduleMap = {};
      }
    } else if (json['schedule'] is Map<String, dynamic>) {
      scheduleMap = Map<String, dynamic>.from(json['schedule']);
    }

    return ThirdCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      image: json['image'] ?? '',
      price: json['price']?.toString() ?? '',
      oneInWeekPrice: json['one_in_week_price']?.toString(),
      twoInWeekPrice: json['two_in_week_price']?.toString(),
      threeInWeekPrice: json['three_in_week_price']?.toString(),
      fourInWeekPrice: json['four_in_week_price']?.toString(),
      fiveInWeekPrice: json['five_in_week_price']?.toString(),
      sixInWeekPrice: json['six_in_week_price']?.toString(),
      onceInMonthPrice: json['once_in_month_price']?.toString(),
      twiceInMonthPrice: json['twice_in_month_price']?.toString(),
      thriceInMonthPrice: json['thrice_in_month_price']?.toString(),
      extraHrPrice: json['extra_hr_price']?.toString() ?? '',
      walletCoins: json['wallet_coins']?.toString() ?? '',
      schedule: scheduleMap,
      materials: json['materials'] != null ? List<MaterialItem>.from((json['materials'] as List).map((x) => MaterialItem.fromJson(x))) : [],
    );
  }
}

class MaterialItem {
  final int id;
  final String name;
  final String? comment;

  MaterialItem({required this.id, required this.name, this.comment});

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(id: json['id'] ?? 0, name: json['name'] ?? '', comment: json['comment']?.toString());
  }
}
