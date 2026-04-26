// Conditional export: selects the IO implementation on native platforms,
// and the web implementation when dart:html is available (Flutter Web).
export 'export_io.dart' if (dart.library.html) 'export_web.dart';
