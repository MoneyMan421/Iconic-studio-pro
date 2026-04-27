import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Triggers a browser download of [bytes] as a PNG file named [suggestedName].
///
/// Returns an empty string on successful download (no local file path exists on
/// the web platform).
Future<String> saveExportedImage(String suggestedName, Uint8List bytes) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = suggestedName;
  anchor.click();
  web.URL.revokeObjectURL(url);
  return '';
}
