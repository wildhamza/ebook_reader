import 'package:ebook_reader/screens/reader_screen.dart';
import 'package:ebook_reader/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";
  String selectedCategory = "All";
  List<Map<String, dynamic>> localBooks = [];

  @override
  void initState() {
    super.initState();
    _loadLocalBooks();
  }

  Future<void> _loadLocalBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedBooks = prefs.getStringList('localBooks');

    if (storedBooks != null) {
      setState(() {
        localBooks = storedBooks.map((book) {
          var details = book.split('|');
          return {
            "title": details.isNotEmpty ? details[0] : "Unknown Title",
            "path": details.length > 1 ? details[1] : "",
            "coverUrl":
                details.length > 2 ? details[2] : "assets/placeholder.jpg",
            "author": details.length > 3 ? details[3] : "Unknown",
          };
        }).toList();
      });
    }
  }

  Future<void> _addBookManually() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
    );

    if (result != null) {
      setState(() {
        localBooks.add({
          "title": result.files.first.name,
          "path": result.files.first.path!,
          "coverUrl": "assets/placeholder.jpg",
          "author": "Unknown",
        });
        var bookpath = result.files.first.path!;
        print(bookpath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        title: Center(
          child: Text(
            'EBook Reader',
            style: GoogleFonts.tajawal(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBookList()),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _addBookManually,
              child: const Icon(
                Icons.add,
                size: 35,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: _loadLocalBooks,
              child: const Icon(
                Icons.edit,
                size: 35,
              ),
            ),
          ),
        ],
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
      bool matchesSearch = searchQuery.isEmpty ||
          book["title"].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSearch;
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
              child: book["coverUrl"].startsWith('assets/')
                  ? Image.asset(
                      book["coverUrl"],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : CachedNetworkImage(
                      imageUrl: book["coverUrl"],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.book),
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
