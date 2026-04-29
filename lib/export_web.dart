import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart';

/// Triggers a browser download of [bytes] as a PNG file named [suggestedName].
///
/// Returns an empty string on successful download (no local file path exists on
/// the web platform).
Future<String> saveExportedImage(String suggestedName, Uint8List bytes) async {
  final blob = Blob(
    [bytes.buffer.toJS].toJS,
    BlobPropertyBag(type: 'image/png'),
  );
  final url = URL.createObjectURL(blob);
  final anchor = document.createElement('a') as HTMLAnchorElement
    ..href = url
    ..download = suggestedName;
  document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  URL.revokeObjectURL(url);
  return '';
}
