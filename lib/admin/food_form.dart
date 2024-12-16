import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jakbites_mobile/food/models/food_model.dart';
import 'package:jakbites_mobile/models/resutarant_model.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class FoodFormPage extends StatefulWidget {
  final Food? food; // Null for add, not null for edit

  const FoodFormPage({super.key, this.food});

  @override
  State<FoodFormPage> createState() => _FoodFormPageState();
}

class _FoodFormPageState extends State<FoodFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _description = "";
  String _category = "";
  int _restaurantId = 0;
  String _price = "";
  List<Restaurant> restaurants = [];

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
    if (widget.food != null) {
      _name = widget.food!.fields.name;
      _description = widget.food!.fields.description;
      _category = widget.food!.fields.category;
      _restaurantId = widget.food!.fields.restaurant;
      _price = widget.food!.fields.price.toString();
    }
  }

  Future<void> fetchRestaurants() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://localhost:8000/json_restaurant/');
    print("Restaurant Response: $response"); // For debugging
    if (!mounted) return;
    
    // The response is already decoded by the CookieRequest class
    setState(() {
      // Directly use the response data without additional jsonEncode
      restaurants = List<Restaurant>.from(
        response.map((data) => Restaurant.fromJson(data))
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    bool isEdit = widget.food != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Food' : 'Add Food'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEdit ? 'Edit Food' : 'Add Food',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: _name,
                      decoration: InputDecoration(
                        labelText: 'Food Name',
                        hintText: 'Enter food name',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5.0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _name = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Food name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      initialValue: _description,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter description',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5.0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _description = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      initialValue: _category,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        hintText: 'Enter category',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5.0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _category = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Category cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    DropdownButtonFormField<int>(
                      value: _restaurantId == 0 ? null : _restaurantId,
                      decoration: InputDecoration(
                        labelText: 'Restaurant',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5.0),
                      ),
                      items: restaurants.map((restaurant) {
                        return DropdownMenuItem(
                          value: restaurant.pk,
                          child: Text(restaurant.fields.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _restaurantId = value ?? 0;
                        });
                      },
                      validator: (value) {
                        if (value == null || value == 0) {
                          return 'Please select a restaurant';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      initialValue: _price,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        hintText: 'Enter price',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5.0),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _price = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price cannot be empty';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (isEdit) {
                            // Edit existing food
                            final response = await request.postJson(
                              "http://localhost:8000/authentication/edit_food_flutter/",
                              jsonEncode({
                                "id": widget.food!.pk,
                                "name": _name,
                                "description": _description,
                                "category": _category,
                                "restaurant": _restaurantId, // Changed from restaurant_id to restaurant
                                "price": int.parse(_price),
                              }),
                            );
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Food updated successfully!"),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response['message'] ??
                                      "Failed to update food."),
                                ),
                              );
                            }
                          } else {
                            // Add new food
                            final response = await request.postJson(
                              "http://localhost:8000/authentication/create_food_flutter/",
                              jsonEncode({
                                "name": _name,
                                "description": _description,
                                "category": _category,
                                "restaurant": _restaurantId, // Changed from restaurant_id to restaurant
                                "price": int.parse(_price),
                              }),
                            );
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("New food saved successfully!"),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response['message'] ??
                                      "Failed to save food."),
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      child: Text(
                        isEdit ? 'Update' : 'Save',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
