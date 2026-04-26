import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Saves [bytes] as a PNG file on native platforms (Android, iOS, desktop).
///
/// On mobile the file is written to the documents / external storage directory.
/// On desktop a native save-file dialog is shown.
/// Returns a human-readable status message describing where the file was saved.
Future<String> saveExportedImage(String suggestedName, Uint8List bytes) async {
  String? savePath;

  if (Platform.isAndroid || Platform.isIOS) {
    Directory? dir;
    if (Platform.isAndroid) {
      try {
        dir = await getExternalStorageDirectory();
      } catch (_) {
        dir = null;
      }
      dir ??= await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    savePath = '${dir.path}/$suggestedName';
  } else {
    // Desktop: show native save dialog.
    final selected = await FilePicker.platform.saveFile(
      dialogTitle: 'Save exported icon',
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: ['png'],
    );
    if (selected == null) return '';
    final hasPng = RegExp(r'\.png$', caseSensitive: false).hasMatch(selected);
    savePath = hasPng ? selected : '$selected.png';
  }

  await File(savePath).writeAsBytes(bytes);
  return savePath;
}
