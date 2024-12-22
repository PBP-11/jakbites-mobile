// lib/pages/profile.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:jakbites_mobile/models/profile_model.dart';
// import 'package:jakbites_mobile/models/restaurant_model.dart'; // Ensure this import is active
// import 'package:jakbites_mobile/models/food_model.dart'; // Ensure this import is active
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

const String baseUrl = 'https://william-matthew31-jakbites.pbp.cs.ui.ac.id'; // Adjust based on your environment

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
  File? _pickedImage; // For mobile
  Uint8List? _pickedImageBytes; // For web

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
    final response = await request.get('$baseUrl/user/get_client_data/');

    if (response['success']) {
      return Profile.fromJson(response['data']);
    } else {
      throw Exception("Failed to load profile: ${response['message']}");
    }
  }

  // Function to pick an image from the gallery
  XFile? _pickedFile; // Use XFile instead of File

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        _pickedImageBytes = await pickedFile.readAsBytes();
      } else {
        _pickedImage = File(pickedFile.path);
      }
      setState(() {});
    }
  }

  // Function to upload the selected profile picture
  Future<void> _uploadProfilePicture() async {
    if ((kIsWeb && _pickedImageBytes == null) || (!kIsWeb && _pickedImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
      return;
    }

    try {
      String base64ImageString;
      if (kIsWeb) {
        base64ImageString = 'data:image/png;base64,${base64Encode(_pickedImageBytes!)}';
      } else {
        List<int> imageBytes = await _pickedImage!.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        base64ImageString = 'data:image/png;base64,$base64Image';
      }

      final request = context.read<CookieRequest>();
      final response = await request.postJson(
        "$baseUrl/user/upload-picture-flutter/",
        jsonEncode({'profile_picture': base64ImageString}),
      );

      print("Upload Profile Picture Response: $response");

      if (response['status'] == 'success') {
        setState(() {
          profileData = fetchProfile(); // Refresh profile data
          _pickedImage = null;
          _pickedImageBytes = null; // Reset the selected image bytes for web
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
    final response = await request.get('$baseUrl/user/get-all-restaurants-flutter/');

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
    final response = await request.get('$baseUrl/user/get-all-foods-flutter/');

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

          // Construct the full URL for the profile picture
          String? profilePictureUrl;
          if (profile.profilePicture != null && profile.profilePicture!.isNotEmpty) {
            // Check if the profilePicture already contains the base URL
            if (profile.profilePicture!.startsWith('http')) {
              profilePictureUrl = profile.profilePicture!;
            } else {
              profilePictureUrl = '$baseUrl${profile.profilePicture}';
            }
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
                          backgroundImage: profilePictureUrl != null
                              ? NetworkImage(profilePictureUrl)
                              : const AssetImage('lib/assets/images/default-profile.png') as ImageProvider,
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
              child: const Text('Cancel', style: TextStyle(color: Colors.white),),
              style: TextButton.styleFrom(backgroundColor: Colors.red,),

              onPressed: () {
                Navigator.of(context).pop();
                _nameController.text = ''; // Reset the controller
              },
            ),
            ElevatedButton(
              child: const Text('Save', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,),

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
                    "$baseUrl/user/change-username-flutter/",
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
              child: const Text('Cancel',style: TextStyle(color: Colors.white), ),
              style: TextButton.styleFrom(backgroundColor: Colors.red,),
              onPressed: () {
                Navigator.of(context).pop();
                _descriptionController.text = ''; // Reset the controller
              },
            ),
            ElevatedButton(
              child: const Text('Save', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,),

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
                    "$baseUrl/user/change-description-flutter/",
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
          content: _alertDialogContent(),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white),),
              style: TextButton.styleFrom(backgroundColor: Colors.red,),

              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _pickedImage = null;
                  _pickedImageBytes = null; // Reset the selected image bytes for web
                });
              },
            ),
            ElevatedButton(
              child: const Text('Upload', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,),

              onPressed: () async {
                if ((kIsWeb && _pickedImageBytes == null) || (!kIsWeb && _pickedImage == null)) {
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

  // Helper function to build the dialog content
  Widget _alertDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kIsWeb)
          _pickedImageBytes != null
              ? Image.memory(
                  _pickedImageBytes!,
                  height: 100,
                  width: 100,
                )
              : const Icon(
                  Icons.account_circle,
                  size: 100,
                )
        else
          _pickedImage != null
              ? Image.file(
                  _pickedImage!,
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
    );
  }

  // Dialog to edit favorite restaurants
  Future<void> _showEditFavoriteRestaurantsDialog(List<Restaurant> currentFavorites) async {
    // Show the dialog and wait for the result
    List<Restaurant>? updatedFavorites = await showDialog<List<Restaurant>>(
      context: context,
      builder: (BuildContext context) {
        // Temporary list to hold selections within the dialog
        List<Restaurant> tempSelectedRestaurants = List.from(currentFavorites);

        return StatefulBuilder(
          builder: (context, setState) {
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
                      initialValue: tempSelectedRestaurants,
                      title: const Text('Restaurants'),
                      searchable: true,
                      listType: MultiSelectListType.LIST,
                      onConfirm: (results) {
                        setState(() {
                          tempSelectedRestaurants = results;
                        });
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
                            tempSelectedRestaurants.remove(item);
                          });
                        },
                      ),
                      cancelText: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red),
                      ),
                      confirmText: Text(
                        "Save",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel', style: TextStyle(color: Colors.white),),
                  style: TextButton.styleFrom(backgroundColor: Colors.red,),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog without returning data
                  },
                ),
                ElevatedButton(
                  child: const Text('Save', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,),
                  onPressed: () {
                    Navigator.of(context).pop(tempSelectedRestaurants); // Return the updated list
                  },
                ),
              ],
            );
          },
        );
      },
    );

    // If the user saved the changes, proceed to update
    if (updatedFavorites != null) {
      List<int> selectedIds = updatedFavorites.map<int>((resto) => resto.id).toList();
      print("Selected Restaurant IDs to send: $selectedIds");

      final request = context.read<CookieRequest>();
      try {
        final response = await request.postJson(
          "$baseUrl/user/update-fav-restaurants-flutter/",
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
    }
  }

  // Dialog to edit favorite foods
  Future<void> _showEditFavoriteFoodsDialog(List<Food> currentFavorites) async {
    // Show the dialog and wait for the result
    List<Food>? updatedFoods = await showDialog<List<Food>>(
      context: context,
      builder: (BuildContext context) {
        // Temporary list to hold selections within the dialog
        List<Food> tempSelectedFoods = List.from(currentFavorites);

        return StatefulBuilder(
          builder: (context, setState) {
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
                      initialValue: tempSelectedFoods,
                      title: const Text('Foods'),
                      searchable: true,
                      listType: MultiSelectListType.LIST,
                      onConfirm: (results) {
                        setState(() {
                          tempSelectedFoods = results;
                        });
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
                            tempSelectedFoods.remove(item);
                          });
                        },
                      ),
                      cancelText: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red),
                      ),
                      confirmText: Text(
                        "Save",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel',style: TextStyle(color: Colors.white),),
                  style: TextButton.styleFrom(backgroundColor: Colors.red,),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog without returning data
                  },
                ),
                ElevatedButton(
                  child: const Text('Save', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue,),

                  onPressed: () {
                    Navigator.of(context).pop(tempSelectedFoods); // Return the updated list
                  },
                ),
              ],
            );
          },
        );
      },
    );

    // If the user saved the changes, proceed to update
    if (updatedFoods != null) {
      List<int> selectedIds = updatedFoods.map<int>((food) => food.id).toList();
      print("Selected Food IDs to send: $selectedIds");

      final request = context.read<CookieRequest>();
      try {
        final response = await request.postJson(
          "$baseUrl/user/update-fav-foods-flutter/",
          jsonEncode({'favorite_foods': selectedIds}),
        );

        print("Update Favorite Foods Response: $response");

        if (response['status'] == 'success') {
          setState(() {
            profileData = fetchProfile(); // Refresh profile data to reflect changes
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
    }
  }
}