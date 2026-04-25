# Flutter-specific ProGuard rules.
# Flutter already ships optimized release builds; these rules keep the
# Flutter embedding and any reflection-based plugins working correctly.

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep plugin classes (reflection used by Flutter plugin registry)
-keep class androidx.** { *; }
-keep class com.google.** { *; }

# Keep app entry point
-keep class com.iconicstudio.pro.** { *; }

# Suppress warnings for missing classes in referenced libraries
-dontwarn io.flutter.**
