# Keep all Stripe classes
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

## Keep everything related to react-native-stripe-sdk
#-keep class com.reactnativestripesdk.** { *; }
#-dontwarn com.reactnativestripesdk.**

# Stripe Push Provisioning keep rules to suppress R8 warnings
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }
# --- Kotlin Coroutines used in Stripe SDK ---
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**
-keep class com.example.social_sharing_plus.** { *; }
-keep class com.your.package.name.** { *; }

## Required to keep JS interfaces used by WebView in Stripe SDK
#-keepclassmembers class * {
#    @android.webkit.JavascriptInterface <methods>;
#}
