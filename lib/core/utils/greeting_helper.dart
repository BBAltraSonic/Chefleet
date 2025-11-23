/// Helper class for generating personalized greetings based on time of day
class GreetingHelper {
  /// Get greeting based on current time
  /// Returns "Good Morning", "Good Afternoon", or "Good Evening"
  static String getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
  
  /// Get personalized greeting with user name
  /// If userName is null, defaults to "Guest"
  static String getPersonalizedGreeting(String? userName) {
    final greeting = getGreeting();
    final name = userName ?? 'Guest';
    return '$greeting, $name';
  }
  
  /// Get motivational subtitle based on time of day
  static String getSubtitle() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Ready to discover your next favorite meal?';
    } else if (hour < 17) {
      return 'What are you craving today?';
    } else {
      return 'Time for dinner? Let\'s find something delicious!';
    }
  }
}
