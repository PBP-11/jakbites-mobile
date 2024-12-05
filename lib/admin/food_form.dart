import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
// import 'package:jakbites_mobile/models/food_model.dart'; // Uncomment when Food model is available

class FoodFormPage extends StatefulWidget {
  // final Food? food; // Uncomment when Food model is available

  const FoodFormPage({super.key /*, this.food*/});

  @override
  State<FoodFormPage> createState() => _FoodFormPageState();
}

class _FoodFormPageState extends State<FoodFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _description = "";
  String _category = "";
  String _restaurantName = "";
  String _price = "";

  @override
  void initState() {
    super.initState();
    // Uncomment and implement when Food model is available
    // if (widget.food != null) {
    //   _name = widget.food!.name;
    //   _description = widget.food!.description;
    //   _category = widget.food!.category;
    //   _restaurantName = widget.food!.restaurantName;
    //   _price = widget.food!.price.toString();
    // }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    bool isEdit = false; // Set to true when editing a food item

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Food' : 'Add Food'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Center(
        child: const Text('Food Form Page - Coming Soon'),
        // Uncomment and implement when ready
        /*
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            // ...existing code...
          ),
        ),
        */
      ),
    );
  }
}
