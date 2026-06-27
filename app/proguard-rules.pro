# ProGuard rules for the app module

# Keep all public classes and methods
-keep public class * {
    public *;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
