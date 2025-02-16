import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:hive/hive.dart';

class AuthService {
  final _supabase = Supabase.instance.client.auth;

  Future<void> signUp(String email, String password) async {
    await _supabase.signUp(email: email, password: password);
  }

  Future<void> signIn(String email, String password) async {
    await _supabase.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.signOut();
  }
}