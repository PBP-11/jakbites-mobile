import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// For CookieRequest
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Restaurant detail
import 'package:jakbites_mobile/models/resutarant_model.dart' as RestoModel;
import 'package:jakbites_mobile/restaurant/restaurant_detail.dart';

// Food detail
import 'package:jakbites_mobile/food/models/food_model.dart' as FoodModel;
import 'package:jakbites_mobile/food/screens/food_detail.dart';

// Profile model
import 'package:jakbites_mobile/models/profile_model.dart';
import 'package:jakbites_mobile/models/menu_model.dart';

// Example color palette
const Color kBackgroundColor = Color(0xFFD1D5DB);
const Color kPrimaryTextColor = Color(0xFF292929);
const Color kAccentColor = Colors.amber;
const Color kLightGrey = Color(0xFFE5E5E5);
const Color kDarkGrey = Color(0xFF757575);
const Color kWhite = Colors.white;

/// Model for "food" object returned from 'foods'


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Main Page
class _MyHomePageState extends State<MyHomePage> {
  /// Filter can be 'food', 'resto', or 'both'
  String selectedCategory = 'food';

  /// Future that fetches the 2-lists data
  late Future<Map<String, dynamic>> _futureData;

  String? username;
  bool _showAllItems = false;

  @override
  void initState() {
    super.initState();
    _futureData = fetchMenuData();
    _loadUsername();
  }

  // Load profile for username
  Future<void> _loadUsername() async {
    try {
      final profile = await fetchProfile();
      setState(() {
        username = profile?.username ?? 'Guest';
      });
    } catch (e) {
      setState(() => username = 'Guest');
      debugPrint('Error loading username: $e');
    }
  }

  /// This calls /search_flut?query= but with an empty query => gets all items
  Future<Map<String, dynamic>> fetchMenuData() async {
    final url = Uri.parse('http://localhost:8000/search_flut?query=');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // We expect: { "foods": [...], "restaurants": [...] }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data from search_flut');
    }
  }

  Future<Profile?> fetchProfile() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) {
      throw Exception("User not logged in");
    }

    const baseUrl = 'http://localhost:8000';
    final response = await request.get('$baseUrl/user/get_client_data/');
    if (response['success']) {
      return Profile.fromJson(response['data']);
    } else {
      throw Exception("Failed to load profile: ${response['message']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const LeftDrawer(),

      // The floating filter button on the bottom-right
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccentColor,
        onPressed: () {
          // Show bottom sheet with filter options
          showModalBottomSheet(
            context: context,
            builder: (ctx) => _buildFilterBottomSheet(ctx),
          );
        },
        child: const Icon(Icons.filter_list),
      ),

      body: CustomScrollView(
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
                  children: [
                    // ---- Container with "Welcome user" + "Resto. Eats. JakBites." 
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
                        vertical: screenHeight * 0.04,
                        horizontal: screenWidth * 0.06,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "Welcome, <username>" on the top-left
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: screenWidth * 0.15,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryTextColor,
                              ),
                              children: [
                                const TextSpan(text: 'Welcome, '),
                                TextSpan(
                                  text: username ?? 'Guest',
                                  style: TextStyle(
                                    color: kAccentColor,  // yellow
                                  ),
                                ),
                                const TextSpan(text: '!'),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),

                          // Single-liner: "Resto. Eats. JakBites."
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.08,  // large
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryTextColor,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Resto'),
                                    TextSpan(
                                      text: '. ',
                                      style: TextStyle(color: kAccentColor),
                                    ),
                                    const TextSpan(text: 'Eats'),
                                    TextSpan(
                                      text: '. ',
                                      style: TextStyle(color: kAccentColor),
                                    ),
                                    const TextSpan(text: 'JakBites'),
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(color: kAccentColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Toggle Row (Now we also have "both" in the bottom sheet)
                    // In main UI, we only show 2 toggles for simplicity:
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = 'resto';
                                _showAllItems = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: (selectedCategory == 'resto')
                                    ? kAccentColor
                                    : kLightGrey,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: Text(
                                'Resto',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: (selectedCategory == 'resto')
                                      ? kPrimaryTextColor
                                      : kDarkGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = 'food';
                                _showAllItems = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: (selectedCategory == 'food')
                                    ? kAccentColor
                                    : kLightGrey,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  topLeft: Radius.circular(0),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: Text(
                                'Food',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: (selectedCategory == 'food')
                                      ? kPrimaryTextColor
                                      : kDarkGrey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // FutureBuilder for the main data
                    FutureBuilder<Map<String, dynamic>>(
                      future: _futureData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final data = snapshot.data ?? {};
                        final foodsJson = data['foods'] as List? ?? [];
                        final restosJson = data['restaurants'] as List? ?? [];

                        final foods = foodsJson.map((f) => SearchFood.fromJson(f)).toList();
                        final restos = restosJson.map((r) => SearchResto.fromJson(r)).toList();

                        // If user selected "both" from bottom sheet, do that
                        if (selectedCategory == 'resto') {
                          // Show restaurants only
                          return _buildRestaurants(context, restos);
                        } else if (selectedCategory == 'food') {
                          // Show foods only
                          return _buildFoods(context, foods);
                        } else {
                          // selectedCategory == 'both' => show both in one column
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Restaurants',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildRestaurants(context, restos),
                              const SizedBox(height: 20),
                              const Text(
                                'Foods',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildFoods(context, foods),
                            ],
                          );
                        }
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

  // -------------------------------------------
  // Bottom sheet with the filter options
  // -------------------------------------------
  Widget _buildFilterBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        runSpacing: 10,
        children: [
          const Text(
            'Filter by:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Resto Only'),
            onTap: () {
              setState(() {
                selectedCategory = 'resto';
                _showAllItems = false;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.fastfood),
            title: const Text('Food Only'),
            onTap: () {
              setState(() {
                selectedCategory = 'food';
                _showAllItems = false;
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.all_inclusive),
            title: const Text('Both'),
            onTap: () {
              setState(() {
                selectedCategory = 'both';
                _showAllItems = false;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------
  // Helper method to build the Resto Grid
  // -------------------------------------------
  Widget _buildRestaurants(BuildContext context, List<SearchResto> restos) {
    // Deduplicate by restaurantId
    final distinctRestoIds = <int>{};
    final deduplicated = <SearchResto>[];
    for (final r in restos) {
      if (!distinctRestoIds.contains(r.restaurantId)) {
        distinctRestoIds.add(r.restaurantId);
        deduplicated.add(r);
      }
    }

    if (deduplicated.isEmpty) {
      return const Center(child: Text('No Resto available.'));
    }

    final itemsToRender = _showAllItems
        ? deduplicated
        : deduplicated.take(4).toList();

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: itemsToRender.map((resto) {
            return InkWell(
              onTap: () {
                // Convert to your Restaurant model
                final restaurant = RestoModel.Restaurant(
                  model: RestoModel.Model.MAIN_RESTAURANT,
                  pk: resto.restaurantId,
                  fields: RestoModel.Fields(
                    name: resto.restaurantName,
                    location: resto.location,
                  ),
                );
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
              child: Container(
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      resto.restaurantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resto.location,
                      style: TextStyle(
                        color: kDarkGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (!_showAllItems && deduplicated.length > 4)
          const SizedBox(height: 16),
        if (!_showAllItems && deduplicated.length > 4)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentColor,
            ),
            onPressed: () => setState(() => _showAllItems = true),
            child: const Text('Show All'),
          ),
      ],
    );
  }

  // -------------------------------------------
  // Helper method to build the Food Grid
  // -------------------------------------------
  Widget _buildFoods(BuildContext context, List<SearchFood> foods) {
    // Deduplicate by foodId
    final distinctFoodIds = <int>{};
    final deduplicated = <SearchFood>[];
    for (final f in foods) {
      if (!distinctFoodIds.contains(f.foodId)) {
        distinctFoodIds.add(f.foodId);
        deduplicated.add(f);
      }
    }

    if (deduplicated.isEmpty) {
      return const Center(child: Text('No Food available.'));
    }

    final itemsToRender = _showAllItems
        ? deduplicated
        : deduplicated.take(4).toList();

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: itemsToRender.map((food) {
            return InkWell(
              onTap: () {
                // Convert to your Food model
                final f = FoodModel.Food(
                  model: FoodModel.Model.MAIN_FOOD,
                  pk: food.foodId,
                  fields: FoodModel.Fields(
                    name: food.foodName,
                    description: food.description,
                    category: food.category,
                    restaurant: food.restaurantId,
                    price: food.price,
                  ),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodPageDetail(f),
                  ),
                );
              },
              child: Container(
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      food.foodName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      food.description,
                      style: TextStyle(
                        color: kDarkGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (!_showAllItems && deduplicated.length > 4)
          const SizedBox(height: 16),
        if (!_showAllItems && deduplicated.length > 4)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentColor,
            ),
            onPressed: () => setState(() => _showAllItems = true),
            child: const Text('Show All'),
          ),
      ],
    );
  }

  // -------------------------------------------
  // The Search Bar => uses CustomSearch
  // -------------------------------------------
  Widget _buildSearchBar(BuildContext context, double screenWidth) {
    return GestureDetector(
      onTap: () {
        showSearch(
          context: context,
          delegate: CustomSearch(),  // We'll define below
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

/// The custom search delegate
class CustomSearch extends SearchDelegate {
  Future<Map<String, dynamic>> fetchSearchData(String query) async {
    final url = Uri.parse('http://localhost:8000/search_flut?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Expect: { "foods": [...], "restaurants": [...] }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load search results');
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  /// Pressing "Enter" or the search icon triggers this
  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchSearchData(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data ?? {};
        final foodsJson = data['foods'] as List? ?? [];
        final restosJson = data['restaurants'] as List? ?? [];

        final allFoodsRaw = foodsJson.map((f) => SearchFood.fromJson(f)).toList();
        final allRestosRaw = restosJson.map((r) => SearchResto.fromJson(r)).toList();

        // Deduplicate foods by foodId
        final distinctFoodIds = <int>{};
        final foods = <SearchFood>[];
        for (final f in allFoodsRaw) {
          if (!distinctFoodIds.contains(f.foodId)) {
            distinctFoodIds.add(f.foodId);
            foods.add(f);
          }
        }

        // Deduplicate restaurants by restaurantId
        final distinctRestoIds = <int>{};
        final restos = <SearchResto>[];
        for (final r in allRestosRaw) {
          if (!distinctRestoIds.contains(r.restaurantId)) {
            distinctRestoIds.add(r.restaurantId);
            restos.add(r);
          }
        }

        if (foods.isEmpty && restos.isEmpty) {
          return const Center(child: Text('No results found.'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurants
              if (restos.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Restaurants',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: restos.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final r = restos[index];
                    return ListTile(
                      title: Text(r.restaurantName),
                      subtitle: Text(r.location),
                      onTap: () {
                        final restaurant = RestoModel.Restaurant(
                          model: RestoModel.Model.MAIN_RESTAURANT,
                          pk: r.restaurantId,
                          fields: RestoModel.Fields(
                            name: r.restaurantName,
                            location: r.location,
                          ),
                        );
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
                    );
                  },
                ),
              ],

              // Foods
              if (foods.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Foods',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: foods.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final f = foods[index];
                    return ListTile(
                      title: Text(f.foodName),
                      subtitle: Text(f.description),
                      onTap: () {
                        final food = FoodModel.Food(
                          model: FoodModel.Model.MAIN_FOOD,
                          pk: f.foodId,
                          fields: FoodModel.Fields(
                            name: f.foodName,
                            description: f.description,
                            category: f.category,
                            restaurant: f.restaurantId,
                            price: f.price,
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodPageDetail(food),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// buildSuggestions => called every time user types a letter
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type something to search.'));
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: fetchSearchData(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data ?? {};
        final foodsJson = data['foods'] as List? ?? [];
        final restosJson = data['restaurants'] as List? ?? [];

        final allFoodsRaw = foodsJson.map((f) => SearchFood.fromJson(f)).toList();
        final allRestosRaw = restosJson.map((r) => SearchResto.fromJson(r)).toList();

        // Deduplicate foods
        final distinctFoodIds = <int>{};
        final foods = <SearchFood>[];
        for (final f in allFoodsRaw) {
          if (!distinctFoodIds.contains(f.foodId)) {
            distinctFoodIds.add(f.foodId);
            foods.add(f);
          }
        }

        // Deduplicate restaurants
        final distinctRestoIds = <int>{};
        final restos = <SearchResto>[];
        for (final r in allRestosRaw) {
          if (!distinctRestoIds.contains(r.restaurantId)) {
            distinctRestoIds.add(r.restaurantId);
            restos.add(r);
          }
        }

        if (foods.isEmpty && restos.isEmpty) {
          return const Center(child: Text('No suggestions.'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurants
              if (restos.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Restaurants',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: restos.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final r = restos[index];
                    return ListTile(
                      title: Text(r.restaurantName),
                      subtitle: Text(r.location),
                      onTap: () {
                        query = r.restaurantName; // fill the search bar
                        final restaurant = RestoModel.Restaurant(
                          model: RestoModel.Model.MAIN_RESTAURANT,
                          pk: r.restaurantId,
                          fields: RestoModel.Fields(
                            name: r.restaurantName,
                            location: r.location,
                          ),
                        );
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
                    );
                  },
                ),
              ],

              // Foods
              if (foods.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Foods',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListView.builder(
                  itemCount: foods.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final f = foods[index];
                    return ListTile(
                      title: Text(f.foodName),
                      subtitle: Text(f.description),
                      onTap: () {
                        query = f.foodName;
                        final food = FoodModel.Food(
                          model: FoodModel.Model.MAIN_FOOD,
                          pk: f.foodId,
                          fields: FoodModel.Fields(
                            name: f.foodName,
                            description: f.description,
                            category: f.category,
                            restaurant: f.restaurantId,
                            price: f.price,
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodPageDetail(food),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}