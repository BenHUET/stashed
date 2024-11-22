import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CacheApiClient {
  static const String _cacheDirectoryName = "cache";

  Future<Uint8List?> get(String filename) async {
    final baseDirectory = await _getDirectory();
    final file = File(p.join(baseDirectory.path, filename));

    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      return bytes;
    }

    return null;
  }

  Future<void> write(String filename, Uint8List content) async {
    final baseDirectory = await _getDirectory();
    final file = File(p.join(baseDirectory.path, filename));

    await file.writeAsBytes(content, mode: FileMode.write);
  }

  Future<Directory> _getDirectory() async {
    final baseDirectory = await getApplicationSupportDirectory();
    final fullDirectory = Directory(p.join(baseDirectory.path, _cacheDirectoryName));
    await fullDirectory.create(recursive: true);
    return fullDirectory;
  }
}
