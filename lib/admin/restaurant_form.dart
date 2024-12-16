import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:jakbites_mobile/models/resutarant_model.dart';

class RestaurantFormPage extends StatefulWidget {
  final Restaurant? restaurant; // Null for add, not null for edit

  const RestaurantFormPage({super.key, this.restaurant});

  @override
  State<RestaurantFormPage> createState() => _RestaurantFormPageState();
}

class _RestaurantFormPageState extends State<RestaurantFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = "";
  String _location = "";

  @override
  void initState() {
    super.initState();
    if (widget.restaurant != null) {
      _name = widget.restaurant!.fields.name;
      _location = widget.restaurant!.fields.location;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
    bool isEdit = widget.restaurant != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Restaurant' : 'Add Restaurant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEdit ? 'Edit Restaurant' : 'Add Restaurant',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: _name,
                      decoration: InputDecoration(
                        labelText: 'Restaurant Name',
                        hintText: 'Enter restaurant name',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5.0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _name = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Restaurant name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      initialValue: _location,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        hintText: 'Enter location',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5.0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _location = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Location cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (isEdit) {
                            // Edit existing restaurant
                            final response = await request.postJson(
                              "http://localhost:8000/edit_restaurant_flutter/",
                              jsonEncode({
                                "id": widget.restaurant!.pk,
                                "name": _name,
                                "location": _location,
                              }),
                            );
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Restaurant updated successfully!"),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response['message'] ??
                                      "Failed to update restaurant."),
                                ),
                              );
                            }
                          } else {
                            // Add new restaurant
                            final response = await request.postJson(
                              "http://localhost:8000/create_restaurant_flutter/",
                              jsonEncode({
                                "name": _name,
                                "location": _location,
                              }),
                            );
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "New restaurant saved successfully!"),
                                ),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response['message'] ??
                                      "Failed to save restaurant."),
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      child: Text(
                        isEdit ? 'Update' : 'Save',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
