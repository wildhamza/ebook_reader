import 'package:ebook_reader/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int _step = 0;

  void _nextStep() {
    if (_step == 0 && _nameController.text.isEmpty) {
      setState(() => _errorMessage = "Please enter your name");
      return;
    }
    if (_step == 1 && !_isValidEmail(_emailController.text)) {
      setState(() => _errorMessage = "Enter a valid email");
      return;
    }
    if (_step == 2 && _passwordController.text.length < 6) {
      setState(() => _errorMessage = "Password must be at least 6 characters");
      return;
    }
    if (_step == 3 && _passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = "Passwords do not match");
      return;
    }
    setState(() {
      _errorMessage = null;
      _step++;
    });
  }

  Future<void> _signup() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userId = response.user?.id;
      if (userId != null) {
        await DatabaseService().saveUserInfo(
          userId,
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(), // Consider hashing before storing
        );
      }

      Navigator.pushReplacementNamed(context, "/home");
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }


  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}").hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> steps = [
      _buildTextField("Name", _nameController, Icons.person),
      _buildTextField("Email", _emailController, Icons.email, keyboardType: TextInputType.emailAddress),
      _buildTextField("Password", _passwordController, Icons.lock, obscureText: true),
      _buildTextField("Confirm Password", _confirmPasswordController, Icons.lock, obscureText: true),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Sign Up",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              steps[_step],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_step < steps.length - 1 ? _nextStep : _signup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    _step < steps.length - 1 ? "Next" : "Sign Up",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Already have an account? Login",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}