# Flutter + flutter_local_notifications ProGuard rules

# Keep all flutter_local_notifications classes
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep GSON (used by flutter_local_notifications for serialization)
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Prevent stripping of BroadcastReceivers
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.app.Service

# Timezone library
-keep class org.threeten.bp.** { *; }
-dontwarn org.threeten.bp.**

# Keep Kotlin coroutines
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
-dontwarn kotlinx.coroutines.**

# Ignore missing Play Store Split Install / Play Core classes referenced by Flutter Play Store split application
-dontwarn com.google.android.play.core.**
