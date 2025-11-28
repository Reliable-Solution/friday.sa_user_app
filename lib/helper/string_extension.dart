import 'dart:developer';

extension StringExtension on String {
  String toCapitalized() {
    // Handle empty string
    if (isEmpty) {
      return this;
    }
    // Convert first letter to uppercase and join with rest of the string
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  // Optional: Add a method to capitalize first letter of each word
  String toTitleCase() {
    // Handle empty string
    if (isEmpty) {
      return this;
    }
    // Split string into words and capitalize each word
    return split('_').map((word) => word.toCapitalized()).join(' ');
  }
}

extension Print on dynamic {
  dynamic get print {
    log(toString(), name: 'Friday User');
    return this;
  }

  dynamic printWithName([String? name]) {
    log(toString(), name: name ?? 'Friday User');
    return this;
  }
}
