import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:epub_view/epub_view.dart';
import 'package:provider/provider.dart';
import 'package:ebook_reader/providers/theme_provider.dart';

class ReaderScreen extends StatefulWidget {
  final String bookPath;
  final String bookTitle;

  const ReaderScreen({super.key, required this.bookPath, required this.bookTitle});

  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool isPdf = false;
  late EpubController _epubController;
  int currentPage = 0;
  int totalPages = 1;
  double progress = 0.0;
  double fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  void _loadBook() {
    try {
      final fileExtension = widget.bookPath.split('.').last.toLowerCase();
      isPdf = fileExtension == "pdf";

      if (!isPdf) {
        File epubFile = File(widget.bookPath);
        if (epubFile.existsSync()) {
          _epubController = EpubController(document: EpubDocument.openFile(epubFile));
        } else {
          print("EPUB file does not exist: \${widget.bookPath}");
        }
      }
    } catch (e) {
      print("Error loading book: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load book: $e")),
        );
      });
    }
  }

  void _changeFontSize(double delta) {
    setState(() {
      fontSize = (fontSize + delta).clamp(12.0, 24.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress),
          Expanded(
            child: isPdf
                ? PDFView(
              filePath: widget.bookPath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageSnap: true,
              fitPolicy: FitPolicy.BOTH,
              onRender: (pages) {
                setState(() {
                  totalPages = pages ?? 1;
                });
              },
              onPageChanged: (page, _) {
                setState(() {
                  currentPage = page ?? 0;
                  progress = (currentPage + 1) / totalPages;
                });
              },
            )
                : _epubController.document != null
                ? EpubView(
              controller: _epubController,
              onChapterChanged: (value) {
                setState(() {
                  progress = value?.progress ?? 0.0;
                });
              },
            )
                : const Center(child: Text("Failed to open EPUB file")),
          ),
        ],
      ),
    );
  }
}
