import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> profileData;

  @override
  void initState() {
    super.initState();
    profileData = fetchProfile();  // Memanggil fungsi fetchProfile
  }

  Future<Map<String, dynamic>> fetchProfile() async {
  final request = context.read<CookieRequest>();

  if (!request.loggedIn) {
    throw Exception("User not logged in");
  }

  // Mengambil data profil dari API Django
  final response = await request.get(
    'http://localhost:8000/user/get_client_data/',
  );

  // Memeriksa apakah response mengandung data atau status error
  if (response['success']) {
    return response['data'];  // Mengambil data profil dari response
  } else {
    throw Exception("Failed to load profile: ${response['message']}");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: profileData,  // Menggunakan data profile yang sudah di-fetch
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
          // Menampilkan data profile di UI
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Username: ${profile['username']}'),
                // Tampilkan data profil lainnya, misalnya:
                Text('Description: ${profile['description']}'),
                // Gambar profil jika ada
                if (profile['profile_picture'] != null)
                  Image.network(profile['profile_picture']),
              ],
            ),
          );
        },
      ),
    );
  }
}
