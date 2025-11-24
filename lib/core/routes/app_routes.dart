/// Route constants for the Chefleet application.
///
/// Routes are organized by role (Customer, Vendor) and shared routes.
/// This ensures clear separation and makes role-based routing easier.

/// Customer-specific routes.
///
/// All customer routes are prefixed with `/customer` to namespace them.
class CustomerRoutes {
  CustomerRoutes._();

  static const String root = '/customer';
  static const String map = '/customer/map';
  static const String dish = '/customer/dish';
  static const String cart = '/customer/cart';
  static const String orders = '/customer/orders';
  static const String chat = '/customer/chat';
  static const String profile = '/customer/profile';
  static const String favourites = '/customer/favourites';
  static const String settings = '/customer/settings';
  static const String notifications = '/customer/notifications';

  /// Returns the dish detail route with the given dish ID.
  static String dishDetail(String dishId) => '$dish/$dishId';

  /// Returns the chat detail route with the given order ID.
  static String chatDetail(String orderId) => '$chat/$orderId';
}

/// Vendor-specific routes.
///
/// All vendor routes are prefixed with `/vendor` to namespace them.
class VendorRoutes {
  VendorRoutes._();

  static const String root = '/vendor';
  static const String dashboard = '/vendor/dashboard';
  static const String orders = '/vendor/orders';
  static const String dishes = '/vendor/dishes';
  static const String analytics = '/vendor/analytics';
  static const String chat = '/vendor/chat';
  static const String profile = '/vendor/profile';
  static const String settings = '/vendor/settings';
  static const String notifications = '/vendor/notifications';

  // Dish management routes
  static const String dishAdd = '/vendor/dishes/add';
  static const String dishEdit = '/vendor/dishes/edit';

  // Order management routes
  static const String orderDetail = '/vendor/orders/detail';

  // Vendor setup routes
  static const String onboarding = '/vendor/onboarding';
  static const String quickTour = '/vendor/quick-tour';
  static const String availability = '/vendor/availability';
  static const String moderation = '/vendor/moderation';

  /// Returns the order detail route with the given order ID.
  static String orderDetailWithId(String orderId) => '$orderDetail/$orderId';

  /// Returns the dish edit route with the given dish ID.
  static String dishEditWithId(String dishId) => '$dishEdit/$dishId';

  /// Returns the availability management route with the given vendor ID.
  static String availabilityWithId(String vendorId) => '$availability/$vendorId';

  /// Returns the chat detail route with the given order ID.
  static String chatDetail(String orderId) => '$chat/$orderId';
}

/// Shared routes accessible from any role.
///
/// These routes are not role-specific and can be accessed by both
/// customers and vendors.
class SharedRoutes {
  SharedRoutes._();

  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String roleSelection = '/role-selection';
  static const String profileCreation = '/profile-creation';
  static const String profileEdit = '/profile/edit';

  /// Routes that guest users can access
  static const List<String> guestAllowedRoutes = [
    auth,
    splash,
  ];

  /// Routes that don't require authentication
  static const List<String> publicRoutes = [
    splash,
    auth,
    roleSelection,
  ];
}

/// Helper class to determine route properties.
class RouteHelper {
  RouteHelper._();

  /// Checks if a route is a customer route.
  static bool isCustomerRoute(String route) {
    return route.startsWith(CustomerRoutes.root);
  }

  /// Checks if a route is a vendor route.
  static bool isVendorRoute(String route) {
    return route.startsWith(VendorRoutes.root);
  }

  /// Checks if a route is a shared route.
  static bool isSharedRoute(String route) {
    return !isCustomerRoute(route) && !isVendorRoute(route);
  }

  /// Checks if a route is public (doesn't require authentication).
  static bool isPublicRoute(String route) {
    return SharedRoutes.publicRoutes.any((publicRoute) =>
        route == publicRoute || route.startsWith('$publicRoute/'));
  }

  /// Checks if a route is allowed for guest users.
  static bool isGuestAllowedRoute(String route) {
    return SharedRoutes.guestAllowedRoutes.any((allowedRoute) =>
        route == allowedRoute || route.startsWith('$allowedRoute/'));
  }

  /// Gets the root route for a given role.
  static String getRootRouteForRole(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return CustomerRoutes.map;
      case 'vendor':
        return VendorRoutes.dashboard;
      default:
        return CustomerRoutes.map;
    }
  }
}
