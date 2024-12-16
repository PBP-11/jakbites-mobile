// To parse this JSON data, do
//
//     final reviewRestaurant = reviewRestaurantFromJson(jsonString);

import 'dart:convert';

ReviewRestaurant reviewRestaurantFromJson(String str) => ReviewRestaurant.fromJson(json.decode(str));

String reviewRestaurantToJson(ReviewRestaurant data) => json.encode(data.toJson());

class ReviewRestaurant {
    int status;
    String message;
    List<Datum> data;

    ReviewRestaurant({
        required this.status,
        required this.message,
        required this.data,
    });

    factory ReviewRestaurant.fromJson(Map<String, dynamic> json) => ReviewRestaurant(
        status: json["status"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    int restaurant;
    String user;
    int rating;
    String review;

    Datum({
        required this.restaurant,
        required this.user,
        required this.rating,
        required this.review,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        restaurant: json["restaurant"],
        user: json["user"],
        rating: json["rating"],
        review: json["review"],
    );

    Map<String, dynamic> toJson() => {
        "restaurant": restaurant,
        "user": user,
        "rating": rating,
        "review": review,
    };
}
