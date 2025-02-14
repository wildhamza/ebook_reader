import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:epub_view/epub_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:ebook_reader/providers/theme_provider.dart'; // Correct import path

class ReaderScreen extends StatefulWidget {
  final String bookUrl;
  final String bookTitle;

  const ReaderScreen({Key? key, required this.bookUrl, required this.bookTitle}) : super(key: key);

  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  String? localPath;
  bool isPdf = false;
  late EpubController _epubController;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    final fileExtension = widget.bookUrl.split('.').last.toLowerCase();
    isPdf = fileExtension == "pdf";

    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/${widget.bookTitle.replaceAll(' ', '_')}.$fileExtension";

    if (await File(filePath).exists()) {
      setState(() {
        localPath = filePath;
      });
    } else {
      await _downloadBook(filePath);
    }

    if (!isPdf) {
      _epubController = EpubController(
        document: EpubDocument.openFile(File(localPath!)),
      );
    }
  }

  Future<void> _downloadBook(String filePath) async {
    try {
      await Dio().download(widget.bookUrl, filePath);
      setState(() {
        localPath = filePath;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load book: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access ThemeProvider

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              themeProvider.toggleTheme(); // Toggle theme using ThemeProvider
            },
          ),
        ],
      ),
      body: localPath == null
          ? const Center(child: CircularProgressIndicator())
          : isPdf
          ? PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageSnap: true,
        fitPolicy: FitPolicy.BOTH,
      )
          : EpubView(
        controller: _epubController,
      ),
    );
  }
}