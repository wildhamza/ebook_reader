// routes.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => LoginScreen(),
  '/home': (context) => const HomeScreen(),
};