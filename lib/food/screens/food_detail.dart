import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:jakbites_mobile/food/models/food_model.dart';
import 'package:jakbites_mobile/food/models/food_review.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class FoodPageDetail extends StatefulWidget {
  final Food food;

  FoodPageDetail(this.food);

  @override
  State<FoodPageDetail> createState() => _FoodPageDetailState();
}

class _FoodPageDetailState extends State<FoodPageDetail> {
  double avgRating = 0.0;

  final TextEditingController _reviewController = TextEditingController();
  double _userRating = 0.0;

  Future<List<Review>> fetchFoodReviews(CookieRequest request) async {
    final response = await request.get(
      'http://localhost:8000/food/get_food_review/',
    );

    if (response == null || response.isEmpty) {
      print('No data received from GET request.');
      return [];
    }

    try {
      // Decode the response into a List
      final responseData = jsonDecode(jsonEncode(response)) as Map<String, dynamic>;
      final reviewList = responseData['review'] as List<dynamic>;

      // Map the reviews into FoodReview objects
      List<Review> foodReviews = reviewList
          .map((review) => Review.fromJson(review))
          .where((review) => review.food == widget.food.fields.name)
          .toList();

      // Calculate the average rating
      if (foodReviews.isNotEmpty) {
        int total = foodReviews.fold(0, (sum, item) => sum + item.rating);
        avgRating = total / foodReviews.length;
      } else {
        avgRating = 0.0;
      }

      return foodReviews;
    } catch (e) {
      print('Error parsing reviews: $e');
      return [];
    }
  }

  Future<void> submitReview(CookieRequest request) async {
    if (_userRating == 0.0 || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide both rating and review.')),
      );
      return;
    }

    Map<String, dynamic> data = {
      'rating': _userRating.toInt(),
      'review': _reviewController.text,
    };

    try {
      final response = await request.postJson(
        'http://localhost:8000/food/add_food_review_flutter/${widget.food.pk}/',
        jsonEncode(data),
      );

      print('Raw Response: $response');

      if (response is Map && response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review submitted successfully!')),
        );
        _reviewController.clear();
        _userRating = 0.0; // Reset user rating
        setState(() {
          // Optionally, re-fetch reviews to include the newly submitted one
          fetchFoodReviews(request);
        });
      } else if (response is Map && response['status'] == 'error') {
        String errorMessage = response['message'] ?? 'Failed to submit review.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $errorMessage')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected response from server.')),
        );
        print('Unexpected Response Format: $response');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
      print('Exception: $e');
    }
  }

  void _deleteReview(Review review) async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final deleteUrl =
        'http://localhost:8000/food/delete_food_review_flutter/${review.reviewid}/';

    try {
      final response = await request.post(deleteUrl, {});

      if (response['success'] == true) {
        setState(() {
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Failed to delete review')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Food Detail'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder<List<Review>>(
            future: fetchFoodReviews(request),
            builder: (context, AsyncSnapshot<List<Review>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Review> reviews = snapshot.data ?? [];
                double averageRating = avgRating;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        widget.food.fields.name,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.food.fields.category} • ${averageRating.toStringAsFixed(1)} ⭐',
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Rp ${widget.food.fields.price}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.restaurant),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    Text(
                      'Reviews',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    reviews.isEmpty
                        ? Center(
                            child: Text(
                              'No reviews yet. Be the first to review!',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (_, index) {
                              final review = reviews[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: ListTile(
                                    leading: Icon(Icons.person, color: Colors.blue),
                                    title: Text(
                                      "${review.author}",
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 5),
                                        Text(
                                          "${review.review}",
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "${review.rating} ⭐",
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: review.isAuthor
                                        ? IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              _deleteReview(review);
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),

                    Divider(),
                    SizedBox(height: 10),
                    Text(
                      'Add a Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        _userRating = rating;
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _reviewController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Write your review',
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        submitReview(request).then((_) {
                          setState(() {});
                        });
                      },
                      child: Text('Submit Review'),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}