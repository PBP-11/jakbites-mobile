// lib/pages/profile.dart

import 'package:flutter/material.dart';
import 'package:jakbites_mobile/models/profile_model.dart';
// import 'package:jakbites_mobile/models/restaurant_model.dart'; // Import Restaurant model
// import 'package:jakbites_mobile/models/food_model.dart'; // Import Food model
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart'; // Import multi_select_flutter
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Profile?> profileData;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool _isInitialized = false; // To ensure controllers are set only once
  File? _selectedImage; // For profile picture

  @override
  void initState() {
    super.initState();
    profileData = fetchProfile(); // Load profile data on initialization
  }

  // Fetching profile data using Profile model
  Future<Profile?> fetchProfile() async {
    final request = context.read<CookieRequest>(); // Access CookieRequest

    // Check if the user is logged in
    if (!request.loggedIn) {
      throw Exception("User not logged in");
    }

    // Send the request to fetch profile data from the Django server
    final response = await request.get('http://localhost:8000/user/get_client_data/');

    // Print the entire response for debugging
    print("Fetch Profile Response: $response");

    if (response['success']) {
      // Print the username from the response
      if (response['data'] != null && response['data'].containsKey('username')) {
        print("Logged in username: ${response['data']['username']}");
      }
      return Profile.fromJson(response['data']);
    } else {
      throw Exception("Failed to load profile: ${response['message']}");
    }
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Function to upload the selected profile picture
  Future<void> _uploadProfilePicture() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
      return;
    }

    try {
      // Convert image to base64
      List<int> imageBytes = await _selectedImage!.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      String base64ImageString = 'data:image/png;base64,$base64Image'; // Adjust MIME type if necessary

      final request = context.read<CookieRequest>();
      final response = await request.postJson(
        "http://localhost:8000/user/upload-picture-flutter/",
        jsonEncode({'profile_picture': base64ImageString}),
      );

      print("Upload Profile Picture Response: $response");

      if (response['status'] == 'success') {
        setState(() {
          profileData = fetchProfile(); // Refresh profile data
          _selectedImage = null; // Reset the selected image
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile picture: ${response['message']}')),
        );
      }
    } catch (e) {
      print("Error in uploading profile picture: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture: $e')),
      );
    }
  }

  // Function to fetch all restaurants as Restaurant objects
  Future<List<Restaurant>> fetchAllRestaurantsObjects() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://localhost:8000/user/get-all-restaurants-flutter/');

    if (response['status'] == 'success') {
      List<dynamic> data = response['data'];
      return data.map((item) => Restaurant.fromJson(item)).toList();
    } else {
      throw Exception("Failed to fetch restaurants: ${response['message']}");
    }
  }

  // Function to fetch all foods as Food objects
  Future<List<Food>> fetchAllFoodsObjects() async {
    final request = context.read<CookieRequest>();
    final response = await request.get('http://localhost:8000/user/get-all-foods-flutter/');

    if (response['status'] == 'success') {
      List<dynamic> data = response['data'];
      return data.map((item) => Food.fromJson(item)).toList();
    } else {
      throw Exception("Failed to fetch foods: ${response['message']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<Profile?>(
        future: profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data available'));
          }

          var profile = snapshot.data!;

          // Initialize controllers only once to prevent resetting on every build
          if (!_isInitialized) {
            _nameController.text = profile.username;
            _descriptionController.text = profile.description;
            _isInitialized = true;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView( // Prevent overflow on smaller screens
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: profile.profilePicture != null
                              ? NetworkImage(profile.profilePicture!)
                              : const AssetImage('assets/default_profile.png') as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditProfilePictureDialog();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Username Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Username:', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditUsernameDialog();
                        },
                      ),
                    ],
                  ),
                  Text(profile.username, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 20),

                  // Description Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Description:', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditDescriptionDialog();
                        },
                      ),
                    ],
                  ),
                  Text(profile.description, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 20),

                  // Favorite Restaurants Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Favorite Restaurants:', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditFavoriteRestaurantsDialog(profile.favoriteRestaurants);
                        },
                      ),
                    ],
                  ),
                  profile.favoriteRestaurants.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: profile.favoriteRestaurants
                              .map((resto) => Text('- ${resto.name} (${resto.location})'))
                              .toList(),
                        )
                      : const Text('No favorite restaurants.'),
                  const SizedBox(height: 20),

                  // Favorite Foods Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Favorite Foods:', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditFavoriteFoodsDialog(profile.favoriteFoods);
                        },
                      ),
                    ],
                  ),
                  profile.favoriteFoods.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: profile.favoriteFoods
                              .map((food) => Text('- ${food.name} (${food.category})'))
                              .toList(),
                        )
                      : const Text('No favorite foods.'),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Dialog to edit username
  void _showEditUsernameDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Username'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Enter new username'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _nameController.text = ''; // Reset the controller
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                String newUsername = _nameController.text.trim();
                if (newUsername.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username cannot be empty.')),
                  );
                  return;
                }

                Navigator.of(context).pop(); // Close the dialog

                // Proceed to send the update request
                final request = context.read<CookieRequest>();
                try {
                  final response = await request.postJson(
                    "http://localhost:8000/user/change-username-flutter/",
                    jsonEncode({'new_value': newUsername}),
                  );

                  print("Change Username Response: $response");

                  if (response['status'] == 'success') {
                    setState(() {
                      profileData = fetchProfile(); // Refresh profile data
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Username updated successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating username: ${response['message']}')),
                    );
                  }
                } catch (e) {
                  print("Error in change username: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating username: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog to edit description
  void _showEditDescriptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Description'),
          content: TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(hintText: 'Enter new description'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _descriptionController.text = ''; // Reset the controller
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                String newDescription = _descriptionController.text.trim();
                if (newDescription.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Description cannot be empty.')),
                  );
                  return;
                }

                Navigator.of(context).pop(); // Close the dialog

                // Proceed to send the update request
                final request = context.read<CookieRequest>();
                try {
                  final response = await request.postJson(
                    "http://localhost:8000/user/change-description-flutter/",
                    jsonEncode({'new_value': newDescription}),
                  );

                  print("Change Description Response: $response");

                  if (response['status'] == 'success') {
                    setState(() {
                      profileData = fetchProfile(); // Refresh profile data
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Description updated successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating description: ${response['message']}')),
                    );
                  }
                } catch (e) {
                  print("Error in change description: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating description: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog to edit profile picture
  void _showEditProfilePictureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      height: 100,
                      width: 100,
                    )
                  : const Icon(
                      Icons.account_circle,
                      size: 100,
                    ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text('Choose Image'),
                onPressed: () {
                  _pickImage();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _selectedImage = null; // Reset the selected image
                });
              },
            ),
            ElevatedButton(
              child: const Text('Upload'),
              onPressed: () async {
                if (_selectedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No image selected.')),
                  );
                  return;
                }

                Navigator.of(context).pop(); // Close the dialog

                // Proceed to upload the image
                await _uploadProfilePicture();
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog to edit favorite restaurants
  // Dialog to edit favorite restaurants
void _showEditFavoriteRestaurantsDialog(List<Restaurant> currentFavorites) {
  // Create a temporary variable to hold the updated favorites
  List<Restaurant> selectedRestaurants = List.from(currentFavorites);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Favorite Restaurants'),
        content: FutureBuilder<List<Restaurant>>(
          future: fetchAllRestaurantsObjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 100,
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(child: Text('No restaurants available.')),
              );
            }

            List<Restaurant> allRestaurants = snapshot.data!;

            return SingleChildScrollView(
              child: MultiSelectDialogField<Restaurant>(
                items: allRestaurants
                    .map((resto) => MultiSelectItem<Restaurant>(resto, resto.name))
                    .toList(),
                initialValue: selectedRestaurants,
                title: const Text('Restaurants'),
                searchable: true,
                listType: MultiSelectListType.LIST,
                onConfirm: (results) {
                  // Update the local variable with the new selections
                  selectedRestaurants = results;
                },
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                chipDisplay: MultiSelectChipDisplay(
                  onTap: (item) {
                    setState(() {
                      selectedRestaurants.remove(item);
                    });
                  },
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog

              // Use the updated 'selectedRestaurants' variable here
              List<int> selectedIds = selectedRestaurants.map<int>((resto) => resto.id).toList();

              final request = context.read<CookieRequest>();
              try {
                final response = await request.postJson(
                  "http://localhost:8000/user/update-fav-restaurants-flutter/",
                  jsonEncode({'favorite_restaurants': selectedIds}),
                );

                print("Update Favorite Restaurants Response: $response");

                if (response['status'] == 'success') {
                  setState(() {
                    profileData = fetchProfile(); // Refresh profile data to reflect changes
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favorite restaurants updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating favorites: ${response['message']}')),
                  );
                }
              } catch (e) {
                print("Error in updating favorite restaurants: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating favorites: $e')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

  // Dialog to edit favorite foods
 // Dialog to edit favorite foods
void _showEditFavoriteFoodsDialog(List<Food> currentFavorites) {
  // Make a local copy of the current favorites
  List<Food> selectedFoods = List.from(currentFavorites);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Favorite Foods'),
        content: FutureBuilder<List<Food>>(
          future: fetchAllFoodsObjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SizedBox(
                height: 100,
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(child: Text('No foods available.')),
              );
            }

            List<Food> allFoods = snapshot.data!;

            return SingleChildScrollView(
              child: MultiSelectDialogField<Food>(
                items: allFoods
                    .map((food) => MultiSelectItem<Food>(food, food.name))
                    .toList(),
                initialValue: selectedFoods,
                title: const Text('Foods'),
                searchable: true,
                listType: MultiSelectListType.LIST,
                onConfirm: (results) {
                  selectedFoods = results;
                },
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                chipDisplay: MultiSelectChipDisplay(
                  onTap: (item) {
                    selectedFoods.remove(item);
                  },
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog

              // Extract the IDs of selected foods
              List<int> selectedIds = selectedFoods.map<int>((food) => food.id).toList();

              // Proceed to send the update request
              final request = context.read<CookieRequest>();
              try {
                final response = await request.postJson(
                  "http://localhost:8000/user/update-fav-foods-flutter/",
                  jsonEncode({'favorite_foods': selectedIds}),
                );

                print("Update Favorite Foods Response: $response");

                if (response['status'] == 'success') {
                  setState(() {
                    // Refresh profile data after successful update
                    profileData = fetchProfile();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favorite foods updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating favorites: ${response['message']}')),
                  );
                }
              } catch (e) {
                print("Error in updating favorite foods: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating favorites: $e')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

}
