import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

/// Triggers a browser download of [bytes] as a PNG file named [suggestedName].
///
/// Returns an empty string on successful download (no local file path exists on
/// the web platform).
///
/// This implementation uses package:web (the modern replacement for dart:html)
/// with dart:js_interop for type-safe browser API access.
Future<String> saveExportedImage(String suggestedName, Uint8List bytes) async {
  // Create a Blob from the image bytes
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  
  // Create an object URL for the blob
  final url = web.URL.createObjectURL(blob);
  
  // Create an anchor element and trigger download
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = suggestedName;
  anchor.click();
  
  // Clean up the object URL
  web.URL.revokeObjectURL(url);
  
  return '';
}
