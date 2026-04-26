/// Selects the correct export implementation at compile time.
/// On web   → export_helper_web.dart  (browser download via dart:html)
/// On io    → export_helper_io.dart   (native file-save via dart:io)
export 'export_helper_stub.dart'
    if (dart.library.html) 'export_helper_web.dart'
    if (dart.library.io) 'export_helper_io.dart';
