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
          const SnackBar(content: Text('Restaurant deleted successfully')),
        );
        fetchItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to delete restaurant')),
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
          const SnackBar(content: Text('Food deleted successfully')),
        );
        fetchItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to delete food')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                  return ExpansionTile(
                    title: Text(
                      restaurantName,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    children: [
                      ListTile(
                        title: Text('Location: $restaurantLocation'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => editItem(restaurant),
                            child: const Text(
                              'Edit',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          TextButton(
                            onPressed: () => deleteItem(restaurant.pk),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                  return ExpansionTile(
                    title: Text(
                      foodName,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    children: [
                      ListTile(
                        title: Text('Category: $foodCategory'),
                        subtitle: Text('Price: \$${food.fields.price.toString()}'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => editItem(food),
                            child: const Text(
                              'Edit',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          TextButton(
                            onPressed: () => deleteItem(food.pk),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
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
