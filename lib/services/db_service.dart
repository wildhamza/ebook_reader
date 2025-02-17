import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  Future<void> saveUserInfo(
      String userId, String name, String email, String password) async {
    await supabase.from('user_information').upsert({
      'id': userId,
      'name': name,
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
