import 'package:ebook_reader/keys/supabase.dart';
import 'package:ebook_reader/screens/home_screen.dart';
import 'package:ebook_reader/screens/login_screen.dart';
import 'package:ebook_reader/screens/signup_screen.dart';
import 'package:ebook_reader/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ebook_reader/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: sb_url,
    anonKey: sb_key,
  );
  final getIt = GetIt.instance;
  //getIt.registerSingleton<CloudStorageService>(CloudStorageService());
  getIt.registerSingleton<DatabaseService>(DatabaseService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                ThemeProvider(context)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'eBook Reader',
            theme: themeProvider.isDarkMode
                ? ThemeData.dark()
                : ThemeData.light(),
            initialRoute: '/login',
            routes: {
              '/home': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
            }
              // Add the following routes
              // '/home': (context) => HomeScreen(),
              // '/login': (context) => LoginScreen(),
          );
        },
      ),
    );
  }
}
