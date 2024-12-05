// lib/models/profile.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class Profile {
  String username;
  String? profilePicture;
  String description;
  List<Restaurant> favoriteRestaurants;
  List<Food> favoriteFoods;

  Profile({
    required this.username,
    this.profilePicture,
    required this.description,
    required this.favoriteRestaurants,
    required this.favoriteFoods,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    var restaurantsJson = json['favorite_restaurants'] as List;
    var foodsJson = json['favorite_foods'] as List;

    return Profile(
      username: json['username'],
      profilePicture: json['profile_picture'],
      description: json['description'],
      favoriteRestaurants: restaurantsJson.map((i) => Restaurant.fromJson(i)).toList(),
      favoriteFoods: foodsJson.map((i) => Food.fromJson(i)).toList(),
    );
  }
}

class Restaurant {
  int id;
  String name;
  String location;

  Restaurant({required this.id, required this.name, required this.location});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }
}

class Food {
  int id;
  String name;
  String category;
  int price;

  Food({required this.id, required this.name, required this.category, required this.price});

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: json['price'],
    );
  }
}

// Fungsi untuk mengambil data profile dari API
Future<Profile?> fetchProfileData() async {
  final response = await http.get(Uri.parse('http://localhost:8000/user/get_client_data/'));

  if (response.statusCode == 200) {
    return Profile.fromJson(json.decode(response.body)['data']);
  } else {
    throw Exception('Failed to load profile data');
  }
}
