// To parse this JSON data, do
//
//     final reviewRestaurant = reviewRestaurantFromJson(jsonString);

import 'dart:convert';

List<ReviewRestaurant> reviewRestaurantFromJson(String str) => List<ReviewRestaurant>.from(json.decode(str).map((x) => ReviewRestaurant.fromJson(x)));

String reviewRestaurantToJson(List<ReviewRestaurant> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewRestaurant {
    int restaurant;
    int userId;
    int rating;
    String review;
    String userName;
    int iD;

    ReviewRestaurant({
        required this.restaurant,
        required this.userId,
        required this.rating,
        required this.review,
        required this.userName,
        required this.iD,
    });

    factory ReviewRestaurant.fromJson(Map<String, dynamic> json) => ReviewRestaurant(
        restaurant: json["restaurant"],
        userId: json["userID"],
        rating: json["rating"],
        review: json["review"],
        userName: json["userName"],
        iD: json["ID"]
    );


    Map<String, dynamic> toJson() => {
        "restaurant": restaurant,
        "userID": userId,
        "rating": rating,
        "review": review,
        "userName": userName,
        "iD" : iD,
    };
}
