// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// Triggers a browser download of the exported PNG.
Future<String> saveExportedIcon(Uint8List bytes) async {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute(
        'download',
        'iconic_export_${DateTime.now().millisecondsSinceEpoch}.png')
    ..click();
  html.Url.revokeObjectUrl(url);
  return 'Icon downloaded — check your browser downloads folder.';
}
