import 'package:flutter/material.dart';
import 'package:gps_tracker/location_display_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Location Demo',
      debugShowCheckedModeBanner: false,
      home: LocationDisplayScreen(),
    );
  }
}
