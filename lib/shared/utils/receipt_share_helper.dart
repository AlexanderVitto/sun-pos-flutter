import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptShareHelper {
  static Future<Uint8List?> captureBoundaryAsPng(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    final boundary =
        boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  static Future<File> writeTempFile(String filename, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final safe = filename.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final file = File('${dir.path}/$safe');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> shareImageFromBoundary(
    GlobalKey boundaryKey, {
    required String filename,
    String? subject,
    String? text,
  }) async {
    final bytes = await captureBoundaryAsPng(boundaryKey);
    if (bytes == null) {
      throw Exception('Gagal mengambil gambar struk');
    }
    final file = await writeTempFile(filename, bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      subject: subject,
      text: text,
    );
  }

  static Future<void> sharePdfBytes(
    Uint8List bytes, {
    required String filename,
    String? subject,
    String? text,
  }) async {
    final file = await writeTempFile(filename, bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: subject,
      text: text,
    );
  }
}
