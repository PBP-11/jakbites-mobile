import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jakbites_mobile/models/resutarant_model.dart';
import 'package:jakbites_mobile/restaurant/restaurant_detail.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RestaurantReview extends StatefulWidget {
  final Restaurant resto;
  RestaurantReview(this.resto, {super.key});

  @override
  State<RestaurantReview> createState() => _RestaurantReviewState();
}

class _RestaurantReviewState extends State<RestaurantReview> {
  final _formkey = GlobalKey<FormState>();
  int _ratingRestaurant = -1;
	String _reviewRestaurant = "";

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    // print(request.cookies.entries.last.value.);
    return Scaffold(
            appBar: AppBar(
              title: const Center(
                child: Text(
                  'Review',
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            // drawer: const LeftDrawer(),
            body: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        maxLength: 255,
                        decoration: InputDecoration(
                          hintText: "Review",
                          labelText: "Review",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            _reviewRestaurant = value!;
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Review produk tidak boleh kosong!";
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "Rating",
                          labelText: "Rating",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        onChanged: (String? value) {
                          setState(() {
                            _ratingRestaurant = int.tryParse(value!) ?? 0;
                          });
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "rating Produk tidak boleh kosong!";
                          }
                          if (int.tryParse(value) == null) {
                            return "rating Produk harus berupa angka!";
                          } 
                          if (int.tryParse(value) != null) {
                            int tmpHargaProduk = int.parse(value);
                            if (tmpHargaProduk <= 0) {
                              return "Produknya tak ada?";
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                Theme.of(context).colorScheme.primary),
                          ),
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Produk telah berhasil tersimpan'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Rating: $_ratingRestaurant'),
                                          Text('Review: $_reviewRestaurant'),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('OK'),
                                        // onPressed: () {
                                        //   Navigator.pop(context);
                                          // _formkey.currentState!.reset();
                                        // },
                                        onPressed: () async {
                                          if (_formkey.currentState!.validate()) {
                                              // Kirim ke Django dan tunggu respons
                                              // TODO: Ganti URL dan jangan lupa tambahkan trailing slash (/) di akhir URL!
                                              final response = await request.postJson(
                                                  "http://localhost:8000/restaurant/crf/",
                                                  jsonEncode(<String, dynamic>{
                                                  // TODO: Sesuaikan field data sesuai dengan aplikasimu
                                                    'restaurant': widget.resto.pk,
                                                    'review': _reviewRestaurant,
                                                    'rating': _ratingRestaurant,
                                                  }),
                                              );
                                              if (context.mounted) {
                                                  if (response['status'] == 'success') {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(const SnackBar(
                                                      content: Text("Produk baru berhasil disimpan!"),
                                                      ));
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => RestaurantPageDetail(widget.resto)),
                                                      );
                                                  } else {
                                                      ScaffoldMessenger.of(context)
                                                          .showSnackBar(const SnackBar(
                                                          content:
                                                              Text("Terdapat kesalahan, silakan coba lagi."),
                                                      ));
                                                  }
                                              }
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            
                          },
                          child: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
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