import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:hive/hive.dart';

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