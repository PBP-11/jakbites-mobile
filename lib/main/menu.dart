import 'package:flutter/material.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';
import 'package:jakbites_mobile/models/menu_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import your Restaurant model & detail page:
import 'package:jakbites_mobile/models/resutarant_model.dart'; 
import 'package:jakbites_mobile/restaurant/restaurant_detail.dart';
// ^^^ Adjust the import paths as needed ^^^

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

                            // If we're on 'resto', wrap in an InkWell to navigate
                            if (selectedCategory == 'resto') {
                              // Convert SearchItem -> Restaurant
                              final restaurant = Restaurant(
                                model: Model.MAIN_RESTAURANT,
                                pk: item.restaurantId,
                                fields: Fields(
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
                              // If 'food', just return the container w/o navigation
                              return container;
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
          delegate: CustomSearch(),
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

// ------------------------- Search Delegate -------------------------
class CustomSearch extends SearchDelegate {
  Future<List<SearchItem>> fetchSearchResults(String query) async {
    final url = Uri.parse('http://localhost:8000/search?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data
          .map((item) => SearchItem.fromJson(item))
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
        close(context, null);
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

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            return ListTile(
              title: Text(item.foodName),
              subtitle: Text(item.description),
              trailing: Text(
                item.category,
                style: TextStyle(
                  color: kDarkGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type something to search.'));
    }

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

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final item = suggestions[index];
            return ListTile(
              title: Text(item.foodName),
              subtitle: Text(item.description),
              trailing: Text(
                item.category,
                style: TextStyle(
                  color: kDarkGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              onTap: () {
                query = item.foodName;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}
