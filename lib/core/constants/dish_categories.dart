/// Dish category constants and utilities
/// 
/// This file provides the mapping between user-friendly display names
/// and database enum values for dish categories.
class DishCategories {
  DishCategories._();

  /// User-friendly category display names for UI
  static const List<String> displayNames = [
    'Appetizers',
    'Main Course',
    'Desserts',
    'Beverages',
    'Snacks',
    'Side Dishes',
  ];

  /// Database enum values (must match the check constraint in the database)
  /// CHECK: category_enum IN ('appetizer', 'main', 'dessert', 'beverage', 'snack', 'side')
  static const List<String> enumValues = [
    'appetizer',
    'main',
    'dessert',
    'beverage',
    'snack',
    'side',
  ];

  /// Map from display name to database enum value
  static const Map<String, String> displayToEnum = {
    'Appetizers': 'appetizer',
    'Main Course': 'main',
    'Desserts': 'dessert',
    'Beverages': 'beverage',
    'Snacks': 'snack',
    'Side Dishes': 'side',
  };

  /// Map from database enum value to display name
  static const Map<String, String> enumToDisplay = {
    'appetizer': 'Appetizers',
    'main': 'Main Course',
    'dessert': 'Desserts',
    'beverage': 'Beverages',
    'snack': 'Snacks',
    'side': 'Side Dishes',
  };

  /// Convert a display name to a database enum value
  /// Returns null if the display name is not recognized
  static String? toEnum(String? displayName) {
    if (displayName == null) return null;
    return displayToEnum[displayName];
  }

  /// Convert a database enum value to a display name
  /// Returns the enum value itself if no mapping is found
  static String toDisplayName(String? enumValue) {
    if (enumValue == null) return '';
    return enumToDisplay[enumValue] ?? enumValue;
  }

  /// Check if a value is a valid database enum value
  static bool isValidEnum(String? value) {
    return value != null && enumValues.contains(value);
  }

  /// Check if a value is a valid display name
  static bool isValidDisplayName(String? value) {
    return value != null && displayNames.contains(value);
  }
}
