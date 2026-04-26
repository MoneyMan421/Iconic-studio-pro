import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

final RegExp _pngPattern = RegExp(r'\.png$', caseSensitive: false);

/// Saves the exported PNG to disk using a platform-appropriate path.
///
/// Returns the saved file path as a human-readable message, or an empty string
/// when the user cancels the desktop save-file dialog.
Future<String> saveExportedIcon(Uint8List bytes) async {
  String savePath;

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
    savePath =
        '${dir.path}/iconic_export_${DateTime.now().millisecondsSinceEpoch}.png';
  } else {
    // Desktop — show native save dialog.
    final selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save exported icon',
      fileName: 'iconic_export.png',
      type: FileType.custom,
      allowedExtensions: ['png'],
    );
    if (selectedPath == null) return '';
    savePath =
        _pngPattern.hasMatch(selectedPath) ? selectedPath : '$selectedPath.png';
  }

  await File(savePath).writeAsBytes(bytes);
  return 'Icon exported to $savePath';
}
