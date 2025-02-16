import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService extends ChangeNotifier {
  final _db = Supabase.instance.client;

  Future<void> saveUserInfo(String userId, String name, String email, String password) async {
    await _db.from('user_information').insert({
      'id': userId,
      'name': name,
      'email': email,
      'password': password, // Consider hashing before storing
    });
  }
}