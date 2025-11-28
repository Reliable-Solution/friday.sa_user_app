// Define an enum for every environment you want to create.
enum Flavor { prod, staging, dev }

// Add more values as needed.
class FlavorValues {
  FlavorValues({
    required this.apiBaseUrl,
    required this.appIcon,
    required this.appName,
  });
  final String apiBaseUrl;
  final String appIcon;
  final String appName;
}

class FlavorConfig {
  factory FlavorConfig({
    required Flavor flavor,
    // Color is an optional value that will be used for the flavor banner.
    // Flavor banner is one way to identify the environment you used.
    // You can remove this line of code if you don't need it.
    required FlavorValues values,
  }) {
    _instance = FlavorConfig._internal(flavor, flavor.name, values);
    return _instance;
  }

  FlavorConfig._internal(this.flavor, this.name, this.values);
  final Flavor flavor;
  final String name;
  final FlavorValues values;
  static late FlavorConfig _instance;

  static FlavorConfig get instance {
    return _instance;
  }

  // Method to check your current environment in your realtime code
  static bool isDevelopment() => _instance.flavor == Flavor.dev;

  static bool isStaging() => _instance.flavor == Flavor.staging;

  static bool isProduction() => _instance.flavor == Flavor.prod;
}
