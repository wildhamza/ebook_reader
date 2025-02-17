import 'dart:io';

import 'package:ebook_reader/providers/theme_provider.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';

class ReaderScreen extends StatefulWidget {
  final String bookPath;
  final String bookTitle;

  const ReaderScreen({
    super.key,
    required this.bookPath,
    required this.bookTitle,
  });

  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool isPdf = false;
  EpubBook? _epubBook;
  List<EpubChapter>? _chapters;
  String? _selectedChapterContent;
  int currentPage = 0;
  int totalPages = 1;
  double progress = 0.0;
  double fontSize = 16.0;
  bool isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  void _changeFontSize(double delta) {
    setState(() {
      fontSize = (fontSize + delta).clamp(12.0, 24.0);
    });
  }

  Future<void> _loadBook() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final fileExtension = widget.bookPath.split('.').last.toLowerCase();
      isPdf = fileExtension == "pdf";

      if (!isPdf) {
        File epubFile = File(widget.bookPath);
        if (epubFile.existsSync()) {
          final epubBytes = await epubFile.readAsBytes();
          _epubBook = await EpubReader.readBook(epubBytes);

          // Debugging prints
          print("EPUB Book Loaded: ${_epubBook?.Title}");
          print("Chapters Found: ${_epubBook?.Chapters?.length}");

          // Retrieve chapters correctly
          _chapters = _epubBook?.Chapters ?? [];
        } else {
          _errorMessage = "EPUB file not found: ${widget.bookPath}";
        }
      }
    } catch (e) {
      _errorMessage = "Failed to load book: $e";
      print("Error loading EPUB: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    LinearProgressIndicator(value: progress),
                    Expanded(
                      child: isPdf ? _buildPdfViewer() : _buildEpubViewer(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPdfViewer() {
    return PDFView(
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
    );
  }

  Widget _buildEpubViewer() {
    if (_selectedChapterContent != null) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedChapterContent = null;
              });
            },
            child: const Text("Back to Chapters"),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Html(data: _selectedChapterContent!),
            ),
          ),
        ],
      );
    }

    if (_chapters == null || _chapters!.isEmpty) {
      return Center(
        child: Text(
          "EPUB loaded but no TOC found. Try navigating manually.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      itemCount: _chapters!.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_chapters![index].Title ?? "Untitled Chapter"),
          onTap: () {
            setState(() {
              _selectedChapterContent = _chapters![index].HtmlContent;
            });
          },
        );
      },
    );
  }
}
