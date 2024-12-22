import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jakbites_mobile/models/resutarant_model.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jakbites_mobile/models/restaurant_review_model.dart';
import 'add_review_restaurant.dart';
import 'package:jakbites_mobile/food/models/food_model.dart';
import 'package:jakbites_mobile/food/screens/food_detail.dart';
import 'package:jakbites_mobile/food/screens/food_list.dart';
import 'package:http/http.dart' as http;

class RestaurantPageDetail extends StatefulWidget {
  final Restaurant resto;
  var isMenu = true;
  RestaurantPageDetail(this.resto, this.isMenu, {super.key});


  @override
  State<RestaurantPageDetail> createState() => _RestaurantPageDetailState();
}

class _RestaurantPageDetailState extends State<RestaurantPageDetail> {  

  Future deleteReview(int id) async {
    // print(id);
  final http.Response response = await http.delete(
    Uri.parse('https://william-matthew31-jakbites.pbp.cs.ui.ac.id/restaurant/drf/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      },
    body: jsonEncode(<String, int>{
      'deleteID': id,
    }),
    );  
    return;
  }

  double avg_rating = 0.0;
  Future<List<ReviewRestaurant>> fetchReviewRestaurant(CookieRequest request) async {
    final response =await request.get('https://william-matthew31-jakbites.pbp.cs.ui.ac.id/json_review_restaurant/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object Food
    List<ReviewRestaurant> listReviewRestaurant = [];
    List<int> ratingRestaurant = [];
    
    for (var d in data['data']) {
      if (d != null) {
        if (d['restaurant'] == widget.resto.pk) {
          ratingRestaurant.add(d["rating"]);
          listReviewRestaurant.add(ReviewRestaurant.fromJson(d));
        }
      }
    }

    ratingRestaurant.isEmpty? avg_rating = 0 : avg_rating = ratingRestaurant.reduce((a, b) => a + b) / ratingRestaurant.length;
    // avg_rating = ratingRestaurant.reduce((a, b) => a + b) / ratingRestaurant.length;
    return listReviewRestaurant;
  }

  Future<List<Food>> fetchFood(CookieRequest request) async {
    final response =
        await request.get('https://william-matthew31-jakbites.pbp.cs.ui.ac.id/json_food/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object Food
    List<Food> listFood = [];
    for (var d in data) {
      if (d != null) {
        // print();
        // print(d['restaurant'] == widget.resto.pk);
        if (d['fields']['restaurant'] == widget.resto.pk) {
          listFood.add(Food.fromJson(d));
        }
      }
    }
    return listFood;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
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
      // drawer: const LeftDrawer(),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Align(
        child: Column(
        children: [
          SizedBox(
            height: 15,
          ),
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
                      widget.isMenu = true;
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
                      widget.isMenu = false;
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
          Flexible(
            child: 
            !widget.isMenu? Column(
              children: [
                Card(
                // MainAxisAlignment: MainAxisAlignment.start,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RestaurantReview(-64, widget.resto, () {setState(() {
                    });})),
                  );
                  }, 
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Text("Buat Review", style: TextStyle(color: Colors.black)),
                  ),
                  ),
              ), SizedBox(height: 10), 
                Flexible(child: Container(
                  child: 
                  FutureBuilder(
                    future: fetchReviewRestaurant(request),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      } else {  
                        if (snapshot.data.length==0) {
                          return Container(
                            alignment: Alignment.center,
                            child: const Text('Yuk tambahkan reviewmu!',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (_, index) => Container(
                              padding: const EdgeInsets.all(2),
                              child: Column(
                                children: [
                                  Builder(
                                    builder: (context) {
                                      if (1==1) {
                                        return Card(
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: Text(
                                                  "${snapshot.data![index].userName}: ${snapshot.data![index].rating}⭐",
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                ),
                                                subtitle: Text(
                                                  "${snapshot.data![index].review}",
                                                    style: const TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  TextButton(
                                                    child: const Text('Update Review',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10
                                                    ),
                                                    ),
                                                    onPressed: () => Navigator.push(
                                                      context,
                                                        MaterialPageRoute(builder: (context) => 
                                                        RestaurantReview(snapshot.data![index].iD,widget.resto, () 
                                                        {setState(() {});}
                                                        )),
                                                        ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  TextButton(
                                                    child: const Text('Delete Review',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                    ),
                                                    ),
                                                    onPressed: () => {
                                                      deleteReview(snapshot.data![index].iD),
                                                      fetchReviewRestaurant(request),
                                                      setState(() {
                                                        }
                                                      )
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                              ),
                                            ],
                                          )
                                        );
                                      } else {
                                        return Card(
                                          child: ListTile(
                                          title: Text(
                                            "${snapshot.data![index].userName}: ${snapshot.data![index].rating}⭐",
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          ),
                                          subtitle: Text(
                                            "${snapshot.data![index].review}",
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }, 
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      };
                    },
                  ),
                ))
              ],
            ): Container(
              child: FutureBuilder(
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
                                          FoodPageDetail(snapshot.data![index]),
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
          ),
        ],  
      ),
      ),
      ), 
    );
  }
}