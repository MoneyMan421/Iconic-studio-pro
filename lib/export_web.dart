// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// Triggers a browser download of [bytes] as a PNG file named [suggestedName].
///
/// Returns an empty string on successful download (no local file path exists on
/// the web platform).
Future<String> saveExportedImage(String suggestedName, Uint8List bytes) async {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', suggestedName)
    ..click();
  html.Url.revokeObjectUrl(url);
  return '';
}
