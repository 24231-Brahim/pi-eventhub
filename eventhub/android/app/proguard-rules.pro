# Keep Google ML Kit barcode scanning classes (used by mobile_scanner).
# These are accessed via reflection/JNI; R8 obfuscation breaks them and
# causes an obfuscated null-reference native crash when opening the camera.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_barcode.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-dontwarn com.google.mlkit.**

# Keep the mobile_scanner plugin classes.
-keep class dev.steenbakker.mobile_scanner.** { *; }
-dontwarn dev.steenbakker.mobile_scanner.**
