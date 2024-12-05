import 'package:flutter/material.dart';
import 'package:jakbites_mobile/authentication/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jakbites_mobile/main/menu.dart';
import 'package:jakbites_mobile/widgets/left_drawer.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Jakbites',
        theme: ThemeData(
          // Base Fonts
          textTheme: GoogleFonts.poppinsTextTheme(textTheme).copyWith(
            bodySmall: GoogleFonts.lora(
              textStyle: textTheme.bodySmall,
              fontSize: 15.0,
            ),
          ),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.grey,
          ).copyWith(
            secondary: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.grey[300],
          appBarTheme: AppBarTheme(
            color: Colors.transparent,
          ),
        ),
        home: const LoginPage(),
      ),
    );
  }
}