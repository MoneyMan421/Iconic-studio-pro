// Conditional export: selects the IO implementation on native platforms,
// and the web implementation when dart:js_interop is available (Flutter Web).
export 'export_io.dart' if (dart.library.js_interop) 'export_web.dart';
