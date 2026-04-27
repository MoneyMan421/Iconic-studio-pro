// Conditional export: selects the IO implementation on native platforms,
// and the web implementation on Flutter Web (detected via dart.library.html).
export 'export_io.dart' if (dart.library.html) 'export_web.dart';
