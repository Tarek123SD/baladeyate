import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Downscales large camera photos before multipart upload so the request
/// does not stall and get reset by the server.
class AttachmentCompressor {
  AttachmentCompressor._();

  static const int _compressAboveBytes = 1024 * 1024;
  static const int _targetWidth = 1280;

  static const Set<String> _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
  };

  static Future<List<PlatformFile>> prepare(List<PlatformFile> files) async {
    final prepared = <PlatformFile>[];
    for (final file in files) {
      prepared.add(await _prepareOne(file));
    }
    return prepared;
  }

  static Future<PlatformFile> _prepareOne(PlatformFile file) async {
    if (!_isImage(file.name) || file.path == null) {
      return file;
    }
    if (file.size > 0 && file.size <= _compressAboveBytes) {
      return file;
    }

    try {
      final originalBytes = await File(file.path!).readAsBytes();
      final codec = await ui.instantiateImageCodec(
        originalBytes,
        targetWidth: _targetWidth,
      );
      final frame = await codec.getNextFrame();
      final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      frame.image.dispose();
      codec.dispose();

      if (png == null) {
        return file;
      }

      final compressed = png.buffer.asUint8List();
      if (file.size > 0 && compressed.length >= file.size) {
        return file;
      }

      final dir = await getTemporaryDirectory();
      final outName = _pngName(file.name);
      final outPath =
          '${dir.path}${Platform.pathSeparator}tx_${DateTime.now().microsecondsSinceEpoch}_$outName';
      await File(outPath).writeAsBytes(compressed, flush: true);

      return PlatformFile(
        name: outName,
        path: outPath,
        size: compressed.length,
      );
    } catch (_) {
      return file;
    }
  }

  static bool _isImage(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) {
      return false;
    }
    return _imageExtensions.contains(name.substring(dot + 1).toLowerCase());
  }

  static String _pngName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0) {
      return '$name.png';
    }
    return '${name.substring(0, dot)}.png';
  }
}
