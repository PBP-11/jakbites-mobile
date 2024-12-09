// To parse this JSON data, do
//
//     final foodReviewEntry = foodReviewEntryFromJson(jsonString);

import 'dart:convert';

FoodReviewEntry foodReviewEntryFromJson(String str) => FoodReviewEntry.fromJson(json.decode(str));

String foodReviewEntryToJson(FoodReviewEntry data) => json.encode(data.toJson());

class FoodReviewEntry {
    List<Review> review;

    FoodReviewEntry({
        required this.review,
    });

    factory FoodReviewEntry.fromJson(Map<String, dynamic> json) => FoodReviewEntry(
        review: List<Review>.from(json["review"].map((x) => Review.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "review": List<dynamic>.from(review.map((x) => x.toJson())),
    };
}

class Review {
    String food;
    int reviewid;
    int rating;
    String review;
    bool isAuthor;
    String author;

    Review({
        required this.food,
        required this.reviewid,
        required this.rating,
        required this.review,
        required this.isAuthor,
        required this.author,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        food: json["food"],
        reviewid: json["reviewid"],
        rating: json["rating"],
        review: json["review"],
        isAuthor: json["is_author"],
        author: json["author"],
    );

    Map<String, dynamic> toJson() => {
        "food": food,
        "reviewid": reviewid,
        "rating": rating,
        "review": review,
        "is_author": isAuthor,
        "author": author,
    };
}
