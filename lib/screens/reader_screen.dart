import 'dart:io';

import 'package:ebook_reader/providers/theme_provider.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chapters_reader_screen.dart';

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
  bool isLoading = true;
  String? _errorMessage;
  int _lastReadChapterIndex = 0;
  int _lastReadPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadLastReadPosition();
    _loadBook();
  }

  Future<void> _loadLastReadPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastReadChapterIndex = prefs.getInt('lastReadChapter') ?? 0;
      _lastReadPage = prefs.getInt('lastReadPage') ?? 0;
    });
  }

  Future<void> _saveLastReadPosition(int chapterIndex, int pageIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastReadChapter', chapterIndex);
    await prefs.setInt('lastReadPage', pageIndex);
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
        title: Text(widget.bookTitle,
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
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
              ? Center(
                  child: Text(_errorMessage!,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))
              : isPdf
                  ? _buildPdfViewer()
                  : _buildChapterList(),
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

  Widget _buildChapterList() {
    return ListView.builder(
      padding: EdgeInsets.all(12.0),
      itemCount: _chapters?.length ?? 0,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Center(
              child: Text(
                _chapters![index].Title ?? "Untitled Chapter",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChapterReader(
                    chapterIndex: index,
                    chapters: _chapters!,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
