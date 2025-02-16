import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (response.user != null) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } on AuthException catch (e) {
      _setErrorMessage(e.message);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void _setErrorMessage(String? errorMessage) {
    _errorMessage = errorMessage;
    notifyListeners();
  }

  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
}
