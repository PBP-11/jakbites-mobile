import 'package:flutter/material.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';
import 'package:jakbites_mobile/models/menu_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import your Restaurant model & detail page:
import 'package:jakbites_mobile/models/resutarant_model.dart' as RestoModel;
import 'package:jakbites_mobile/restaurant/restaurant_detail.dart';

// Import your Food model & detail page:
import 'package:jakbites_mobile/food/models/food_model.dart' as FoodModel;
import 'package:jakbites_mobile/food/screens/food_detail.dart';

// Example of a simplified color palette for consistency
const Color kBackgroundColor = Color(0xFFD1D5DB); // Main background
const Color kPrimaryTextColor = Color(0xFF292929); // Dark text
const Color kAccentColor = Colors.amber;           // Accent
const Color kLightGrey = Color(0xFFE5E5E5);        // Light grey
const Color kDarkGrey = Color(0xFF757575);         // Dark grey
const Color kWhite = Colors.white;                 // White

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedCategory = 'food'; // Can be 'food' or 'resto'
  late Future<List<SearchItem>> _futureItems;

  Future<List<SearchItem>> fetchMenuItems() async {
    // Single endpoint returning all matching items
    final url = Uri.parse('http://localhost:8000/search?query=');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      List<SearchItem> items = data
          .map((item) => SearchItem.fromJson(item))
          .toList()
          .cast<SearchItem>();
      return items;
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureItems = fetchMenuItems();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const LeftDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ------------------- App Bar -------------------
          SliverAppBar(
            backgroundColor: kBackgroundColor,
            pinned: true,
            expandedHeight: 150.0,
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: Image.asset(
                      'lib/assets/images/logo1.png',
                      width: screenWidth * 0.08,
                      height: screenWidth * 0.05,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  'Enaknya makan apa ya?',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(screenWidth * 0.1),
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.04,
                  right: screenWidth * 0.04,
                  bottom: 10,
                ),
                child: _buildSearchBar(context, screenWidth),
              ),
            ),
          ),

          // ------------------- Body -------------------
          SliverToBoxAdapter(
            child: Container(
              color: kBackgroundColor,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ---- 1) "Resto." and "Eats." box ----
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: screenHeight * 0.03),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.04,  // vertical padding
                        horizontal: screenWidth * 0.06, // horizontal padding
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // First row (Resto)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.25,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryTextColor,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Resto'),
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(
                                        color: kAccentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          // Second row (Eats)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.25,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryTextColor,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Eats'),
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(
                                        color: kAccentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ---- 2) Toggle Row (Resto / Food) ----
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = 'resto';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedCategory == 'resto'
                                    ? kAccentColor
                                    : kLightGrey,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(0),
                                ),
                                boxShadow: selectedCategory == 'resto'
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Resto',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selectedCategory == 'resto'
                                      ? kPrimaryTextColor
                                      : kDarkGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = 'food';
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedCategory == 'food'
                                    ? kAccentColor
                                    : kLightGrey,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  topLeft: Radius.circular(0),
                                ),
                                boxShadow: selectedCategory == 'food'
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Food',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selectedCategory == 'food'
                                      ? kPrimaryTextColor
                                      : kDarkGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // ---- 3) Future builder (grid) ----
                    FutureBuilder<List<SearchItem>>(
                      future: _futureItems,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.1),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final allItems = snapshot.data ?? [];

                        // If showing restaurants, extract distinct restaurants
                        List<SearchItem> displayItems;
                        if (selectedCategory == 'resto') {
                          // We want distinct restaurants
                          final seenRestaurants = <String>{};
                          final uniqueRestaurants = <SearchItem>[];
                          for (var item in allItems) {
                            if (!seenRestaurants.contains(item.restaurantName)) {
                              seenRestaurants.add(item.restaurantName);
                              uniqueRestaurants.add(item);
                            }
                          }
                          displayItems = uniqueRestaurants;
                        } else {
                          // If it's food, show all items
                          displayItems = allItems;
                        }

                        if (displayItems.isEmpty) {
                          return const Center(child: Text('No items available.'));
                        }

                        // Show max of 4 items for your grid
                        final gridItems = displayItems.length > 4
                            ? displayItems.sublist(0, 4)
                            : displayItems;

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: gridItems.map((item) {
                            final title = (selectedCategory == 'resto')
                                ? item.restaurantName
                                : item.foodName;
                            final subtitle = (selectedCategory == 'resto')
                                ? item.location
                                : item.description;

                            // The core container content
                            final container = Container(
                              decoration: BoxDecoration(
                                color: kWhite,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryTextColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: screenWidth * 0.01),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.025,
                                      color: kDarkGrey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );

                            // If we're on 'resto', wrap in an InkWell to navigate to Restaurant
                            if (selectedCategory == 'resto') {
                              // Convert SearchItem -> Restaurant
                              final restaurant = RestoModel.Restaurant(
                              model: RestoModel.Model.MAIN_RESTAURANT,
                              pk: item.restaurantId,
                              fields: RestoModel.Fields(
                                name: item.restaurantName,
                                location: item.location,
                              ),
                            );

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RestaurantPageDetail(
                                        restaurant,
                                        true,
                                      ),
                                    ),
                                  );
                                },
                                child: container,
                              );
                            } else {
                              // If 'food', wrap in an InkWell to navigate to Food
                              final food = FoodModel.Food(
                              model: FoodModel.Model.MAIN_FOOD,
                              pk: item.foodId,
                              fields: FoodModel.Fields(
                                name: item.foodName,
                                description: item.description,
                                category: item.category,
                                restaurant: item.restaurantId,
                                price: item.price,
                              ),
                            );


                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FoodPageDetail(food),
                                    ),
                                  );
                                },
                                child: container,
                              );
                            }
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- Search Bar -------------------
  Widget _buildSearchBar(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: () {
        showSearch(
          context: context,
          delegate: CustomSearch(), // See below
        );
      },
      child: Container(
        width: double.infinity,
        height: screenWidth * 0.1,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: kDarkGrey,
              size: screenWidth * 0.04,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'Nom..nom..nomm',
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: kDarkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnifiedItem {
  final bool isRestaurant;
  final SearchItem data;
  
  _UnifiedItem({
    required this.isRestaurant,
    required this.data,
  });
}


// ------------------------- Search Delegate -------------------------
class CustomSearch extends SearchDelegate {
  // 1) fetchSearchResults: calls your Django endpoint
  Future<List<SearchItem>> fetchSearchResults(String query) async {
    final url = Uri.parse('http://localhost:8000/search?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      // We assume each item in `data` is an object with { food_id, food_name, ... restaurant: {...} }
      return data
          .map((jsonObj) => SearchItem.fromJson(jsonObj))
          .toList()
          .cast<SearchItem>();
    } else {
      throw Exception('Failed to load search results');
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // Close the search overlay
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<SearchItem>>(
      future: fetchSearchResults(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return const Center(child: Text('No results found.'));
        }

        // -------------------------------------------------------
        // 1) Build a map of distinct restaurants by restaurantId
        //    Key = restaurantId, Value = one representative SearchItem
        // -------------------------------------------------------
        final distinctRestaurantMap = <int, SearchItem>{};
        for (final item in results) {
          final rid = item.restaurantId;
          if (!distinctRestaurantMap.containsKey(rid)) {
            distinctRestaurantMap[rid] = item;
          }
        }

        // Distinct restaurant items
        final distinctRestaurants = distinctRestaurantMap.values.toList();

        // -------------------------------------------------------
        // 2) Build the final combined list
        //    We want to show distinct restaurants + all foods
        // -------------------------------------------------------
        final combinedList = <_UnifiedItem>[];

        // (a) Add each distinct restaurant as isRestaurant=true
        for (final restoItem in distinctRestaurants) {
          combinedList.add(
            _UnifiedItem(isRestaurant: true, data: restoItem),
          );
        }

        // (b) Add every item as isRestaurant=false (food)
        for (final foodItem in results) {
          combinedList.add(
            _UnifiedItem(isRestaurant: false, data: foodItem),
          );
        }

        // 3) Display them all in one ListView
        return ListView.builder(
          itemCount: combinedList.length,
          itemBuilder: (context, index) {
            final unified = combinedList[index];
            final item = unified.data;

            // Title depends on whether it's a restaurant or food
            final title = unified.isRestaurant
                ? item.restaurantName
                : item.foodName;

            // Subtitle too:
            final subtitle = unified.isRestaurant
                ? item.location
                : item.description;

            return ListTile(
              title: Text(title),
              subtitle: Text(subtitle),
              onTap: () {
                if (unified.isRestaurant) {
                  // Navigate to Restaurant
                  final restaurant = RestoModel.Restaurant(
                    model: RestoModel.Model.MAIN_RESTAURANT,
                    pk: item.restaurantId,
                    fields: RestoModel.Fields(
                      name: item.restaurantName,
                      location: item.location,
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantPageDetail(restaurant, true),
                    ),
                  );
                } else {
                  // Navigate to Food
                  final food = FoodModel.Food(
                    model: FoodModel.Model.MAIN_FOOD,
                    pk: item.foodId,
                    fields: FoodModel.Fields(
                      name: item.foodName,
                      description: item.description,
                      category: item.category, // not used for logic
                      restaurant: item.restaurantId,
                      price: item.price,
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodPageDetail(food),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // If query is empty, just show "Type something" placeholder
    if (query.isEmpty) {
      return const Center(child: Text('Type something to search.'));
    }

    // Otherwise, do the same logic for partial suggestions
    return FutureBuilder<List<SearchItem>>(
      future: fetchSearchResults(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final suggestions = snapshot.data ?? [];
        if (suggestions.isEmpty) {
          return const Center(child: Text('No suggestions.'));
        }

        // Same approach: distinct restaurants + all foods
        final distinctRestaurantMap = <int, SearchItem>{};
        for (final item in suggestions) {
          final rid = item.restaurantId;
          if (!distinctRestaurantMap.containsKey(rid)) {
            distinctRestaurantMap[rid] = item;
          }
        }

        final distinctRestaurants = distinctRestaurantMap.values.toList();

        final combinedList = <_UnifiedItem>[];

        // restaurants
        for (final rItem in distinctRestaurants) {
          combinedList.add(_UnifiedItem(isRestaurant: true, data: rItem));
        }
        // foods
        for (final fItem in suggestions) {
          combinedList.add(_UnifiedItem(isRestaurant: false, data: fItem));
        }

        return ListView.builder(
          itemCount: combinedList.length,
          itemBuilder: (context, index) {
            final unified = combinedList[index];
            final item = unified.data;

            final title = unified.isRestaurant
                ? item.restaurantName
                : item.foodName;

            final subtitle = unified.isRestaurant
                ? item.location
                : item.description;

            return ListTile(
              title: Text(title),
              subtitle: Text(subtitle),
              onTap: () {
                query = title; // fill the search bar

                if (unified.isRestaurant) {
                  final restaurant = RestoModel.Restaurant(
                    model: RestoModel.Model.MAIN_RESTAURANT,
                    pk: item.restaurantId,
                    fields: RestoModel.Fields(
                      name: item.restaurantName,
                      location: item.location,
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantPageDetail(restaurant, true),
                    ),
                  );
                } else {
                  final food = FoodModel.Food(
                    model: FoodModel.Model.MAIN_FOOD,
                    pk: item.foodId,
                    fields: FoodModel.Fields(
                      name: item.foodName,
                      description: item.description,
                      category: item.category,
                      restaurant: item.restaurantId,
                      price: item.price,
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodPageDetail(food),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
