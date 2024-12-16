import 'package:flutter/material.dart';
import 'package:jakbites_mobile/admin/admin_page.dart';
import 'package:jakbites_mobile/authentication/login.dart';
import 'package:jakbites_mobile/admin/restaurant_form.dart';
import 'package:jakbites_mobile/main/menu.dart';
import 'package:jakbites_mobile/restaurant/restaurant_list.dart';
import 'package:jakbites_mobile/user/profile.dart';
// import 'package:jakbites_mobile/list_ProductEntry.dart';
// import 'package:jakbites_mobile/food_resto.dart'; // Import Food Resto screen
// import 'package:jakbites_mobile/auth/login.dart'; // Import Login screen

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.fastfood,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'JakBites Mobile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Delicious food, just a click away!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Menu Items
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home_outlined,
                  title: 'Main Page',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.place,
                  title: 'Restaurants',
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RestaurantPage()),
                  );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.restaurant,
                  title: 'Foods',
                  onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => const FoodRestoPage()),
                  //   );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.admin_panel_settings,
                  title: 'Admin Page',
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPage()),
                  );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.account_circle,
                  title: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>const ProfilePage()),
                    );
                  },
                ),
              ],
            ),
          ),
          // Logout/Login Section
          const Divider(),
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout/Login',
            onTap: () {
              Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Reusable Drawer Item Builder
  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
