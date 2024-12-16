import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jakbites_mobile/models/resutarant_model.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jakbites_mobile/models/restaurant_review_model.dart';
import 'add_review_restaurant.dart';
import 'package:jakbites_mobile/food/models/food_model.dart';
import 'package:jakbites_mobile/food/screens/food_detail.dart';
import 'package:jakbites_mobile/food/screens/food_list.dart';

class RestaurantPageDetail extends StatefulWidget {
  final Restaurant resto;
  RestaurantPageDetail(this.resto, {super.key});

  @override
  State<RestaurantPageDetail> createState() => _RestaurantPageDetailState();
}

class _RestaurantPageDetailState extends State<RestaurantPageDetail> {  
  Future<List<Food>> fetchFood(CookieRequest request) async {
    final response =
        await request.get('http://127.0.0.1:8000/json_food/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object Food
    List<Food> listFood = [];
    for (var d in data) {
      if (d != null) {
        if (d['restaurant'] == widget.resto.pk) {
          listFood.add(Food.fromJson(d));
        }
      }
    }
    return listFood;
  }
  // print(context.watch<CookieRequest>);
  double avg_rating = 0.0;
  Future<List<String>> fetchReviewRestaurant(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/json_review_restaurant/');
    
    // Melakukan decode response menjadi bentuk json
    var data = response;
    // print(data);
    
    // Melakukan konversi data json menjadi object MoodEntry
    List<String> listReviewerName = [];
    List<String> listReviewRestaurant = [];
    List<int> ratingRestaurant = [];
    // print(widget.resto.pk == );
    for (var d in data['data']) {
      // print(d["restaurant"]);
      // print(widget.resto.pk);
      if (d != null) {
        // print(d['data']["restaurant"]);
        if (d["restaurant"] == widget.resto.pk) {
          // print(d);
          // listReviewerName.add(d['user']);
          var temp = d['user']+': '+d["rating"].toString()+'⭐   '+d['review'];
          listReviewRestaurant.add(temp);
          // listReviewRestaurant.add(ReviewRestaurant.fromJson(d));
          ratingRestaurant.add(d["rating"]);
        }
      }
    }
    // print(ratingRestaurant);
    avg_rating = ratingRestaurant.reduce((a, b) => a + b) / ratingRestaurant.length;

    return listReviewRestaurant;
  }

  bool ismenu = true;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Align(
        child: Column(
        children: [
          Flexible(child: FutureBuilder(
            future: fetchReviewRestaurant(request), 
            builder: (context, AsyncSnapshot snapshot) {
              return Builder(
                builder: (BuildContext context) => ListTile(
                title: Text(
                    widget.resto.fields.name,
                    // textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                ),
                subtitle: Text(
                    widget.resto.fields.location + "       " + avg_rating.toString() + " ⭐",
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                trailing: SvgPicture.asset(
                    'lib/assets/images/resto.svg',
                    width: 50,
                    height: 50,
                  ),
                ),
              );
            }
          ),
          ),
          Flexible(child: 
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                // MainAxisAlignment: MainAxisAlignment.start,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      ismenu = true;
                    });
                  }, 
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text("Menu", style: TextStyle(color: Colors.black)),
                  ),
                  ),
              ),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      ismenu = false;
                    });
                  },  
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text("Review", style: TextStyle(color: Colors.black)),
                  ),
                  ),
              ),
            ],
          ),
          ),
          Flexible(
            child: 
            !ismenu? Column(
              children: [
                Card(
                // MainAxisAlignment: MainAxisAlignment.start,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RestaurantReview(widget.resto)),
                  );
                  }, 
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text("Buat Review", style: TextStyle(color: Colors.black)),
                  ),
                  ),
              ),
                Flexible(child: Container(
                  child: 
                  FutureBuilder(
                    future: fetchReviewRestaurant(request),
                    builder: (context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return const Column(
                            children: [
                              Text(
                                'Belum Ada Review Makanan Pada JakBites',
                                style: TextStyle(fontSize: 20, color: Colors.black),
                              ),
                              SizedBox(height: 8),
                            ],
                          );
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (_, index) => Container(
                              padding: const EdgeInsets.all(2),
                              child: Column(
                                children: [
                                  Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                    child: InkWell( 
                                      child: Column(
                                        children: <Widget>[
                                            ListTile(
                                              title: Text(
                                                "${snapshot.data![index]}",
                                                  style: const TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                    ),
                                ],
                              ),
                            ),
                          );
                        }
                    },
                  ),
                ))
              ],
            ): 
              FutureBuilder(
        future: fetchFood(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'Belum ada data makanan pada JakBites',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => Container(
                  padding: const EdgeInsets.all(2),
                  child: Column(
                    children: [
                      Card(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  // FoodPageDetail(snapshot.data![index]),
                                  FoodPage(),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  "${snapshot.data![index].fields.name}",
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "${snapshot.data![index].fields.category}",
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: const Icon(Icons.restaurant),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // const Image(
                      // image: AssetImage('lib/assets/images/resto.png'),
                      // ),
                      // Text(
                      //   "${snapshot.data![index].fields.name}",
                      //   style: const TextStyle(
                      //     fontSize: 18.0,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              );
            }
          }
        },
      ),
          ),
        ],
      ),
      ),
      ), 
    );
  }
}