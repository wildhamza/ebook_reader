import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class OfflineService {
  late Box _box;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    _box = await Hive.openBox('ebook_cache');
  }

  void saveBook(String id, Map<String, dynamic> bookData) {
    _box.put(id, bookData);
  }

  Map<String, dynamic>? getBook(String id) {
    return _box.get(id);
  }
}
