import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jakbites_mobile/models/resutarant_model.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jakbites_mobile/models/restaurant_review_model.dart';

class RestaurantPageDetail extends StatefulWidget {
  final Restaurant resto;
  RestaurantPageDetail(this.resto);

  @override
  State<RestaurantPageDetail> createState() => _RestaurantPageDetailState();
}


class _RestaurantPageDetailState extends State<RestaurantPageDetail> {
  double avg_rating = 0.0;
  Future<List<ReviewRestaurant>> fetchReviewRestaurant(CookieRequest request) async {
    final response = await request.get('http://loaclhost:8000/json_review_restaurant/');
    
    // Melakukan decode response menjadi bentuk json
    var data = response;
    
    // Melakukan konversi data json menjadi object MoodEntry
    List<ReviewRestaurant> listReviewRestaurant = [];
    List<int> ratingRestaurant = [];
    // print(widget.resto.pk == );
    for (var d in data) {
      if (d != null) {
        if (d['fields']["restaurant"] == widget.resto.pk) {
          listReviewRestaurant.add(ReviewRestaurant.fromJson(d));
          ratingRestaurant.add(d['fields']["rating"]);
        }
      }
    }

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
          Expanded(
            child: 
            !ismenu? Container(
            child: 
            FutureBuilder(
              future: fetchReviewRestaurant(request),
              builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return const Column(
                      children: [
                        Text(
                          'Belum Menu Makanan Pada JakBites',
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
                                // onTap: () => Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => RestaurantPageDetail(snapshot.data![index]),
                                //   ),
                                // ),
                                child: Column(
                                  children: <Widget>[
                                      ListTile(
                                        title: Text(
                                          "${snapshot.data![index].fields.review}",
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        ),
                                        // subtitle: Text(
                                        //   "${snapshot.data![index].fields.location}",
                                        //     style: const TextStyle(
                                        //       fontSize: 12.0,
                                        //       fontWeight: FontWeight.bold,
                                        //     ),
                                        // ),
                                        // trailing: SvgPicture.asset(
                                        //   'lib/assets/images/resto.svg',
                                        //   width: 50,
                                        //   height: 50,
                                        //   ),
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
              },
            ),
          ): Text("yang ngurusin food tolong urusin serealizer sama modelnya yak")
          ),
        ],
      ),
      ),
      ), 
    );
  }
}