// lib/models/profile.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class Profile {
  final String username;
  final String? profilePicture;
  final String description;
  final List<Restaurant> favoriteRestaurants;
  final List<Food> favoriteFoods;

  Profile({
    required this.username,
    required this.profilePicture,
    required this.description,
    required this.favoriteRestaurants,
    required this.favoriteFoods,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    var restoList = json['favorite_restaurants'] as List<dynamic>;
    List<Restaurant> favoriteRestaurants = restoList.map((resto) => Restaurant.fromJson(resto)).toList();

    var foodList = json['favorite_foods'] as List<dynamic>;
    List<Food> favoriteFoods = foodList.map((food) => Food.fromJson(food)).toList();

    return Profile(
      username: json['username'],
      profilePicture: json['profile_picture'],
      description: json['description'],
      favoriteRestaurants: favoriteRestaurants,
      favoriteFoods: favoriteFoods,
    );
  }
}

class Restaurant {
  final int id;
  final String name;
  final String location;

  Restaurant({required this.id, required this.name, required this.location});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }

  @override
  String toString() => name;
}

class Food {
  final int id;
  final String name;
  final String category;
  final double price;

  Food({required this.id, required this.name, required this.category, required this.price});

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
    );
  }

  @override
  String toString() => name;
}

// Fetching profile data using API
// Future<Profile?> fetchProfileData() async {
//   final response = await http.get(Uri.parse('http://localhost:8000/user/get_client_data/'));

//   if (response.statusCode == 200) {
//     return Profile.fromJson(json.decode(response.body)['data']);
//   } else {
//     throw Exception('Failed to load profile data');
//   }
// }

// // Update username
// Future<bool> updateUsername(String newName) async {
//   final response = await http.post(
//     Uri.parse('http://localhost:8000/user/profile/change-name/'),
//     headers: {'Content-Type': 'application/json'},
//     body: json.encode({'new_value': newName}),
//   );

//   return response.statusCode == 200;
// }

// // Update description
// Future<bool> updateDescription(String newDescription) async {
//   final response = await http.post(
//     Uri.parse('http://localhost:8000/user/profile/change-description/'),
//     headers: {'Content-Type': 'application/json'},
//     body: json.encode({'new_value': newDescription}),
//   );

//   return response.statusCode == 200;
// }
