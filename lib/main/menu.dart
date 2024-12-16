import 'package:flutter/material.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';
import 'package:jakbites_mobile/models/menu_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      List<SearchItem> items = data.map((item) => SearchItem.fromJson(item)).toList().cast<SearchItem>();
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
          SliverAppBar(
            backgroundColor: const Color(0xFFD1D5DB),
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
                    color: const Color(0xFF292929),
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
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFd1d5db),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Calorie lovers, langsung cari aja disini!',
                     style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Buttons to select mode
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
                                color: selectedCategory == 'resto' ? Colors.amber : Colors.grey.shade300,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(0), // No right curve for connection
                                ),
                                boxShadow: selectedCategory == 'resto'
                                    ? [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(0, 3), // Slightly raised
                                        ),
                                      ]
                                    : [],
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 12, // Adjust for desired height
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Resto',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selectedCategory == 'resto' ? Colors.black : Colors.grey.shade700,
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
                                color: selectedCategory == 'food' ? Colors.amber : Colors.grey.shade300,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  topLeft: Radius.circular(0), // No left curve for connection
                                ),
                                boxShadow: selectedCategory == 'food'
                                    ? [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(0, 3), // Slightly raised
                                        ),
                                      ]
                                    : [],
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 12, // Adjust for desired height
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Food',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selectedCategory == 'food' ? Colors.black : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),


                    SizedBox(height: screenHeight * 0.02),

                    FutureBuilder<List<SearchItem>>(
                      future: _futureItems,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.1),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final allItems = snapshot.data ?? [];

                        // If showing restaurants, extract distinct restaurants
                        List<SearchItem> displayItems;
                        if (selectedCategory == 'resto') {
                          // We want distinct restaurants
                          // Use a Set to track unique restaurant names
                          Set<String> seenRestaurants = {};
                          List<SearchItem> uniqueRestaurants = [];
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

                        final gridItems = displayItems.length > 4 ? displayItems.sublist(0, 4) : displayItems;

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: gridItems.map((item) {
                            // If we're displaying restaurants, we might want to show restaurant info primarily.
                            // If food, show the food info.
                            final title = (selectedCategory == 'resto') 
                              ? item.restaurantName 
                              : item.foodName;
                            final subtitle = (selectedCategory == 'resto') 
                              ? item.location 
                              : item.description;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
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
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: screenWidth * 0.01),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.025,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: screenWidth * 0.03),
            Icon(Icons.search, color: Colors.grey.shade700, size: screenWidth * 0.04),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'Nom..nom..nomm',
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSearch extends SearchDelegate {
  Future<List<SearchItem>> fetchSearchResults(String query) async {
    final url = Uri.parse('http://localhost:8000/search?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((item) => SearchItem.fromJson(item)).toList().cast<SearchItem>();
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
            // Here we show all results as they are just from search
            return ListTile(
              title: Text(item.foodName),
              subtitle: Text(item.description),
              trailing: Text(
                item.category,
                style: TextStyle(
                  color: Colors.grey.shade600,
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
                  color: Colors.grey.shade600,
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

