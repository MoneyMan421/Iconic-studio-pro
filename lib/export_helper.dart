// Conditional export: selects the IO implementation on native platforms,
// and the browser implementation on Flutter Web.
export 'export_io.dart' if (dart.library.html) 'export_web.dart';
