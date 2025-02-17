import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebook_reader/screens/reader_screen.dart';
import 'package:ebook_reader/screens/settings_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";
  List<Map<String, dynamic>> localBooks = [];
  Color _color1 = Colors.deepPurple;
  Color _color2 = Colors.indigo;

  @override
  void initState() {
    super.initState();
    _loadLocalBooks();
    _startColorAnimation();
    _scanDownloadsFolder();
  }

  void _startColorAnimation() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _color1 = Color.fromARGB(
            255, Random().nextInt(100) + 100, Random().nextInt(100) + 100, 255);
        _color2 = Color.fromARGB(
            255, Random().nextInt(100) + 100, Random().nextInt(100) + 100, 255);
      });
    });
  }

  Future<void> _loadLocalBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedBooks = prefs.getStringList('localBooks');

    setState(() {
      localBooks = storedBooks?.map((book) {
            var details = book.split('|');
            return {
              "title": details.isNotEmpty ? details[0] : "Unknown Title",
              "path": details.length > 1 ? details[1] : "",
              "coverUrl":
                  details.length > 2 ? details[2] : "assets/placeholder.jpg",
              "author": details.length > 3 ? details[3] : "Unknown",
            };
          }).toList() ??
          [];
    });
  }

  Future<void> _scanDownloadsFolder() async {
    Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      List<FileSystemEntity> files = downloadsDir.listSync(recursive: true);
      for (var file in files) {
        if (file.path.endsWith('.epub') || file.path.endsWith('.pdf')) {
          var book = {
            "title": file.path.split('/').last,
            "path": file.path,
            "coverUrl": "assets/placeholder.jpg",
            "author": "Unknown",
          };
          if (!localBooks.any((b) => b["path"] == book["path"])) {
            setState(() {
              localBooks.add(book);
            });
          }
        }
      }
    }
  }

  Future<void> _addBookManually() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var book = {
        "title": file.path.split('/').last,
        "path": file.path,
        "coverUrl": "assets/placeholder.jpg",
        "author": "Unknown",
      };
      if (!localBooks.any((b) => b["path"] == book["path"])) {
        setState(() {
          localBooks.add(book);
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> storedBooks = localBooks.map((book) {
          return "${book["title"]}|${book["path"]}|${book["coverUrl"]}|${book["author"]}";
        }).toList();
        prefs.setStringList('localBooks', storedBooks);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AnimatedContainer(
          duration: const Duration(seconds: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_color1, _color2],
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'EBook Reader',
              style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBookList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBookManually,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Search books...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildBookList() {
    List<Map<String, dynamic>> filteredBooks = localBooks.where((book) {
      return searchQuery.isEmpty ||
          book["title"].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return filteredBooks.isEmpty
        ? const Center(child: Text("No books found"))
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: filteredBooks.length,
            itemBuilder: (context, index) {
              return _buildBookCard(filteredBooks[index]);
            },
          );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReaderScreen(
              bookTitle: book["title"],
              bookPath: book['path'],
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: book["coverUrl"],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.book, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book["title"],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                book["author"] ?? "Unknown",
                style:
                    GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
