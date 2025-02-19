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

  const ReaderScreen(
      {super.key, required this.bookPath, required this.bookTitle});

  @override
  _ReaderScreenState createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool isPdf = false;
  EpubBook? _epubBook;
  List<EpubChapter>? _chapters;
  String? _selectedChapterContent;
  bool isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      isPdf = widget.bookPath.toLowerCase().endsWith(".pdf");

      if (!isPdf) {
        File epubFile = File(widget.bookPath);
        if (epubFile.existsSync()) {
          final epubBytes = await epubFile.readAsBytes();
          _epubBook = await EpubReader.readBook(epubBytes);
          _chapters = _epubBook?.Chapters != null
              ? _flattenChapters(_epubBook!.Chapters!)
              : [];
        } else {
          _errorMessage = "EPUB file not found: ${widget.bookPath}";
        }
      }
    } catch (e) {
      _errorMessage = "Failed to load book: $e";
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<EpubChapter> _flattenChapters(List<EpubChapter> chapters) {
    List<EpubChapter> allChapters = [];
    void extractChapters(EpubChapter chapter) {
      if (chapter.HtmlContent != null && chapter.HtmlContent!.isNotEmpty) {
        allChapters.add(chapter);
      }
      if (chapter.SubChapters != null && chapter.SubChapters!.isNotEmpty) {
        for (var subChapter in chapter.SubChapters!) {
          extractChapters(subChapter);
        }
      }
    }

    for (var chapter in chapters) {
      extractChapters(chapter);
    }
    return allChapters;
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
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : isPdf
                  ? _buildPdfViewer()
                  : _buildEpubViewer(),
    );
  }

  Widget _buildPdfViewer() {
    return PDFView(
      filePath: widget.bookPath,
      enableSwipe: true,
      autoSpacing: true,
      pageSnap: true,
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
      return const Center(
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
              _selectedChapterContent =
                  _chapters![index].HtmlContent ?? "No content available";
            });
          },
        );
      },
    );
  }
}
