// models/book_model.dart
class BookModel {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String fileUrl;
  final String format;
  BookModel({required this.id, required this.title, required this.author, required this.coverUrl, required this.fileUrl, required this.format});
}