# Icon Assets Directory

This directory is declared in `pubspec.yaml` as an asset bundle location but currently contains no bundled icon files.

## Purpose

This directory is available for future use to bundle pre-designed icon templates or sample graphics that users can load directly into the editor without importing external files.

## Current Status

Empty (contains only `.gitkeep` placeholder).

## Usage Notes

If you add icon files here:
1. They will be bundled with the app at build time
2. They can be loaded using `rootBundle.load('assets/icons/filename.png')`
3. Remember to reference them correctly in the code

## Size Considerations

Bundled assets increase the app size. Only include essential files that should be available offline.
