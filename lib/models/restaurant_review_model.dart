// To parse this JSON data, do
//
//     final reviewRestaurant = reviewRestaurantFromJson(jsonString);

import 'dart:convert';

List<ReviewRestaurant> reviewRestaurantFromJson(String str) => List<ReviewRestaurant>.from(json.decode(str).map((x) => ReviewRestaurant.fromJson(x)));

String reviewRestaurantToJson(List<ReviewRestaurant> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewRestaurant {
    String model;
    int pk;
    Fields fields;

    ReviewRestaurant({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory ReviewRestaurant.fromJson(Map<String, dynamic> json) => ReviewRestaurant(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int restaurant;
    int user;
    int rating;
    String review;

    Fields({
        required this.restaurant,
        required this.user,
        required this.rating,
        required this.review,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
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
