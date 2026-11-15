# ML Kit Text Recognition optional language script dependencies
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# KeepRemind Native Alarm Architecture & Models
-keep class com.keepremind.alarm.** { *; }
-keepclassmembers class com.keepremind.alarm.** { *; }

# Flutter Local Notifications plugin
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Firebase messaging & analytics
-dontwarn com.google.firebase.**
