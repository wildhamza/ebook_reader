import 'package:ebook_reader/providers/auth_provider.dart';
import 'package:ebook_reader/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _fontSize = 16;
  bool _scrollMode = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble("fontSize") ?? 16;
      _scrollMode = prefs.getBool("scrollMode") ?? true;
    });
  }

  Future<void> _updateSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("fontSize", _fontSize);
    prefs.setBool("scrollMode", _scrollMode);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dark Mode Toggle
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text("Dark Mode"),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),
            const Divider(),

            // Font Size Adjustment
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: Text("Font Size: ${_fontSize.toInt()}"),
            ),
            Slider(
              min: 12,
              max: 30,
              divisions: 9,
              value: _fontSize,
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
                _updateSettings();
              },
            ),
            const Divider(),

            // Page Mode Selection
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text("Reading Mode"),
              subtitle: Text(_scrollMode ? "Scrolling" : "Page Turning"),
              trailing: Switch(
                value: _scrollMode,
                onChanged: (value) {
                  setState(() {
                    _scrollMode = value;
                  });
                  _updateSettings();
                },
              ),
            ),
            const Divider(),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  AuthProvider().logout(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child:
                    const Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
