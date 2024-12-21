import 'dart:convert';

class SearchItem {
  final int foodId;
  final String foodName;
  final String category;
  final int price;
  final String description;
  final String restaurantName;
  final String location;
  final int restaurantId;

  SearchItem({
    required this.foodId,
    required this.foodName,
    required this.category,
    required this.price,
    required this.description,
    required this.restaurantName,
    required this.location,
    required this.restaurantId,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      foodId: json['food_id'],
      foodName: json['food_name'],
      category: json['category'],
      price: json['price'],
      description: json['description'],
      restaurantName: json['restaurant']['restaurant_name'],
      location: json['restaurant']['location'],
      restaurantId: json['restaurant']['restaurant_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'category': category,
      'price': price,
      'description': description,
      'restaurant': {
        'restaurant_name': restaurantName,
        'location': location,
        'restaurant_id': restaurantId,
      }
    };
  }

  static List<SearchItem> fromJsonList(String str) {
    final data = json.decode(str);
    return List<SearchItem>.from(data.map((x) => SearchItem.fromJson(x)));
  }

  static String toJsonList(List<SearchItem> list) {
    return json.encode(List<dynamic>.from(list.map((x) => x.toJson())));
  }
}

class SearchFood {
  final int foodId;
  final String foodName;
  final String category;
  final int price;
  final String description;
  final int restaurantId;
  final String restaurantName;
  final String location;

  SearchFood({
    required this.foodId,
    required this.foodName,
    required this.category,
    required this.price,
    required this.description,
    required this.restaurantId,
    required this.restaurantName,
    required this.location,
  });

  factory SearchFood.fromJson(Map<String, dynamic> json) {
    return SearchFood(
      foodId: json['food_id'],
      foodName: json['food_name'],
      category: json['category'],
      price: json['price'],
      description: json['description'],
      restaurantId: json['restaurant']['restaurant_id'],
      restaurantName: json['restaurant']['restaurant_name'],
      location: json['restaurant']['location'],
    );
  }
}

/// Model for "restaurant" object returned from 'restaurants'
class SearchResto {
  final int restaurantId;
  final String restaurantName;
  final String location;

  SearchResto({
    required this.restaurantId,
    required this.restaurantName,
    required this.location,
  });

  factory SearchResto.fromJson(Map<String, dynamic> json) {
    return SearchResto(
      restaurantId: json['restaurant_id'],
      restaurantName: json['restaurant_name'],
      location: json['location'],
    );
  }
}