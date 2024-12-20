import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jakbites_mobile/models/resutarant_model.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jakbites_mobile/restaurant/restaurant_detail.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({super.key});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  Future<List<Restaurant>> fetchRestaurant(CookieRequest request) async {

    final response = await request.get('http://localhost:8000/json_restaurant/');
    
    // Melakukan decode response menjadi bentuk json
    var data = response;
    
    // Melakukan konversi data json menjadi object MoodEntry
    List<Restaurant> listRestaurant = [];
    // print("HEHEHEHE");
    for (var d in data) {
      if (d != null) {
        listRestaurant.add(Restaurant.fromJson(d));
      }
    }
    // print(listRestaurant);
    // print("HAHAHAHAA");
    return listRestaurant;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find your suite restaurant'),
      ),
      // drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchRestaurant(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } 
          else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'Belum ada data Restaurant pada JakBites',
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        child: InkWell(  
                        //   onTap: () {
                        //   // Menampilkan pesan SnackBar saat kartu ditekan.
                        //   ScaffoldMessenger.of(context)
                        //     ..hideCurrentSnackBar()
                        //     ..showSnackBar(
                        //       SnackBar(content: Text("Kamu telah menekan tombol ${snapshot.data![index].fields.name}!"))
                        //     );
                        // },
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantPageDetail(snapshot.data![index], true),
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
                                    "${snapshot.data![index].fields.location}",
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
    );
  }
}