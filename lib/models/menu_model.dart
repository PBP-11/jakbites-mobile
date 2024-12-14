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
