import 'package:flutter/material.dart';
import 'package:jakbites_mobile/models/resutarant_model.dart';
import 'package:jakbites_mobile/admin/restaurant_form.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
// import 'package:jakbites_mobile/models/food_model.dart'; // Uncomment when Food model is available
// import 'package:jakbites_mobile/admin/food_form.dart'; // Uncomment when FoodFormPage is implemented
import 'dart:convert';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0; // 0 for Restaurant, 1 for Food
  String searchQuery = "";
  List<Restaurant> restaurants = [];
  // List<Food> foods = []; // Placeholder for Food items

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final request = context.read<CookieRequest>();
    if (_currentIndex == 0) {
      // Fetch Restaurants
      final response = await request.get(
          'https://william-matthew31-jakbites.pbp.cs.ui.ac.id/get_restaurants_flutter/');
      setState(() {
        restaurants = restaurantFromJson(jsonEncode(response));
      });
    } else {
      // Fetch Foods (to be implemented)
      // final response = await request.get('https://william-matthew31-jakbites.pbp.cs.ui.ac.id/get_foods_flutter/');
      // setState(() {
      //   foods = foodFromJson(jsonEncode(response));
      // });
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
      // Add Food (to be implemented)
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => const FoodFormPage()),
      // ).then((value) => fetchItems());
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
      // Edit Food (to be implemented)
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => FoodFormPage(food: item)),
      // ).then((value) => fetchItems());
    }
  }

  void deleteItem(int id) async {
    final request = context.read<CookieRequest>();
    if (_currentIndex == 0) {
      // Delete Restaurant
      final response = await request.postJson(
        'https://william-matthew31-jakbites.pbp.cs.ui.ac.id/delete_restaurant_flutter/',
        jsonEncode({"id": id}),
      );
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant deleted successfully')),
        );
        fetchItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete restaurant')),
        );
      }
    } else {
      // Delete Food (to be implemented)
      // final response = await request.postJson(
      //   'https://william-matthew31-jakbites.pbp.cs.ui.ac.id/delete_food_flutter/',
      //   jsonEncode({"id": id}),
      // );
      // if (response['status'] == 'success') {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Food deleted successfully')),
      //   );
      //   fetchItems();
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Failed to delete food')),
      //   );
      // }
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
          // List of Items
          Expanded(
            child: ListView.builder(
              itemCount: _currentIndex == 0 ? restaurants.length : 0,
              // Replace 0 with foods.length when foods are implemented
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
                  // Food item placeholder
                  // ...existing code...
                  return const SizedBox.shrink();
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
