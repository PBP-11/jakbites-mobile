import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jakbites_mobile/admin/food_form.dart';
import 'package:jakbites_mobile/admin/restaurant_form.dart';
import 'package:jakbites_mobile/food/models/food_model.dart';
import 'package:jakbites_mobile/models/resutarant_model.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0; // 0 for Restaurant, 1 for Food
  String searchQuery = "";
  List<Restaurant> restaurants = [];
  List<Food> foods = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final request = context.read<CookieRequest>();
    if (_currentIndex == 0) {
      // Fetch Restaurants
      final response = await request.get('http://localhost:8000/json_restaurant/');
      if (!mounted) return;
      setState(() {
        restaurants = restaurantFromJson(jsonEncode(response));
      });
    } else {
      // Fetch Foods
      final response = await request.get('http://localhost:8000/json_food/');
      if (!mounted) return;
      setState(() {
        foods = foodFromJson(jsonEncode(response));
      });
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      searchQuery = "";
      fetchItems();
    });
  }

  void addItem() {
    if (_currentIndex == 0) {
      // Add Restaurant
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RestaurantFormPage(),
        ),
      ).then((value) => fetchItems());
    } else {
      // Add Food
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FoodFormPage()),
      ).then((value) => fetchItems());
    }
  }

  void editItem(dynamic item) {
    if (_currentIndex == 0) {
      // Edit Restaurant
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantFormPage(restaurant: item),
        ),
      ).then((value) => fetchItems());
    } else {
      // Edit Food
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodFormPage(food: item),
        ),
      ).then((value) => fetchItems());
    }
  }

  void deleteItem(int id) async {
    final request = context.read<CookieRequest>();
    if (_currentIndex == 0) {
      // Delete Restaurant
      final response = await request.postJson(
        'http://localhost:8000/authentication/delete_restaurant_flutter/',
        jsonEncode({"id": id}),
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restaurant deleted successfully'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
          ),
        );
        fetchItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to delete restaurant'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          ),
        );
      }
    } else {
      // Delete Food
      final response = await request.postJson(
        'http://localhost:8000/authentication/delete_food_flutter/',
        jsonEncode({"id": id}),
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food deleted successfully'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
          ),
        );
        fetchItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to delete food'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
        backgroundColor: Colors.grey[50], // Match login page app bar
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                labelStyle: Theme.of(context).textTheme.bodySmall,
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _currentIndex == 0 ? restaurants.length : foods.length,
              itemBuilder: (context, index) {
                if (_currentIndex == 0) {
                  // Restaurant item
                  Restaurant restaurant = restaurants[index];
                  String restaurantName = restaurant.fields.name;
                  String restaurantLocation = restaurant.fields.location;
                  if (searchQuery.isNotEmpty &&
                      !restaurantName.toLowerCase().contains(searchQuery.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        restaurantName,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location: $restaurantLocation',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => editItem(restaurant),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      minimumSize: const Size(80, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    ),
                                    child: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8.0),
                                  ElevatedButton(
                                    onPressed: () => deleteItem(restaurant.pk),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.black87,
                                      minimumSize: const Size(80, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Food item
                  Food food = foods[index];
                  String foodName = food.fields.name;
                  String foodCategory = food.fields.category;
                  if (searchQuery.isNotEmpty &&
                      !foodName.toLowerCase().contains(searchQuery.toLowerCase()) &&
                      !foodCategory.toLowerCase().contains(searchQuery.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        foodName,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category: $foodCategory',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Price: ${food.fields.price.toString()}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => editItem(food),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.black,
                                      minimumSize: const Size(80, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    ),
                                    child: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8.0),
                                  ElevatedButton(
                                    onPressed: () => deleteItem(food.pk),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.black87,
                                      minimumSize: const Size(80, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(bottom: 16), // Adjust bottom margin as needed
        child: FloatingActionButton(
          onPressed: addItem,
          backgroundColor: Colors.white,
          shape: CircleBorder(
            side: BorderSide(color: Colors.black, width: 2),
          ),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Foods',
          ),
        ],
      ),
    );
  }
}