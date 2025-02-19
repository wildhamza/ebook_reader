import 'dart:async';
import 'dart:math';

import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class ChapterReader extends StatefulWidget {
  final int chapterIndex;
  final List<EpubChapter> chapters;

  const ChapterReader({
    super.key,
    required this.chapterIndex,
    required this.chapters,
  });

  @override
  _ChapterReaderState createState() => _ChapterReaderState();
}

class _ChapterReaderState extends State<ChapterReader> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _startColorAnimation();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (currentScroll <= 0 && widget.chapterIndex > 0) {
      _navigateToChapter(widget.chapterIndex - 1);
    } else if (currentScroll >= maxScroll &&
        widget.chapterIndex < widget.chapters.length - 1) {
      _navigateToChapter(widget.chapterIndex + 1);
    }
  }

  void _navigateToChapter(int newIndex) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterReader(
          chapterIndex: newIndex,
          chapters: widget.chapters,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Color _color1 = Colors.deepPurple;
  Color _color2 = Colors.indigo;

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.chapters[widget.chapterIndex].Title ?? "Chapter",
              textAlign: TextAlign.center,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: themeProvider.toggleTheme,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20.0),
        physics: BouncingScrollPhysics(),
        child:
            Html(data: widget.chapters[widget.chapterIndex].HtmlContent ?? ""),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.chapterIndex > 0)
              IconButton(
                tooltip: 'Previous Chapter',
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                ),
                onPressed: () => _navigateToChapter(widget.chapterIndex - 1),
              ),
            if (widget.chapterIndex < widget.chapters.length - 1)
              IconButton(
                tooltip: 'Next Chapter',
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                ),
                onPressed: () => _navigateToChapter(widget.chapterIndex + 1),
              ),
          ],
        ),
      ),
    );
  }
}
