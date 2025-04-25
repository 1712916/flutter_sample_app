# Keep Conscrypt classes
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# Keep OkHttp platform classes
-keep class okhttp3.internal.platform.** { *; }
-dontwarn okhttp3.internal.platform.**

# Optional: Suppress warnings for other potential issues
-dontwarn java.security.**
