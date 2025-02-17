import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class StorageService {
  final _storage = Supabase.instance.client.storage;

  Future<String> uploadFile(File file, String bucket, String path) async {
    final response = await _storage.from(bucket).upload(path, file);
    return response;
  }

  Future<String> getFileUrl(String bucket, String path) async {
    return _storage.from(bucket).getPublicUrl(path);
  }
}