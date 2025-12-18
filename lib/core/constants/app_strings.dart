class AppStrings {
  // Common
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String close = 'Close';
  static const String error = 'Error';
  static const String noDataAvailable = 'No data available';
  static const String loading = 'Loading...';
  
  // Offline
  static const String offlineMode = 'Offline Mode';
  static const String offlineMessage = 'You are currently offline. Some features may be unavailable.';
  static const String gotIt = 'Got it';
  static const String noDishesFound = 'No dishes found'; // Added

  // Vendor Dashboard
  static const String sales = 'Sales';
  static const String orders = 'Orders';
  static const String rating = 'Rating';
  static const String revenue = 'Revenue';
  static const String preparationTime = 'Preparation Time';
  static const String activeOrders = 'Active Orders';
  static const String orderHistory = 'Order History';
  static const String menuItems = 'Menu Items';
  
  static const String analyticsTitle = 'Order Analytics';
  static const String overviewTab = 'Overview';
  static const String performanceTab = 'Performance';
  static const String itemsTab = 'Items';
  
  static const String totalOrders = 'Total Orders';
  static const String totalRevenue = 'Total Revenue';
  static const String avgOrderValue = 'Avg Order Value';
  static const String completionRate = 'Completion Rate';
  static const String orderStatusBreakdown = 'Order Status Breakdown';
  static const String revenueTrend = 'Revenue Trend';
  
  static const String performanceMetrics = 'Performance Metrics';
  static const String avgPrepTime = 'Average Prep Time';
  static const String onTimeRate = 'On-Time Rate';
  static const String dailyAverage = 'Daily Average';
  static const String categoryPerformance = 'Category Performance';

  static const String analyticsError = 'Error loading analytics';
  static const String peakHours = 'Peak Hours';
  static const String noPeakHourData = 'No peak hour data available';
  static const String prepTimeDistribution = 'Preparation time distribution';
  static const String customerFeedback = 'Customer Feedback';
  static const String popularItems = 'Popular Items';
  static const String noItemData = 'No item data available';
  
  // Vendor Orders
  static const String acceptOrder = 'Accept Order';
  static const String rejectOrder = 'Reject Order';
  static const String completeOrder = 'Complete Order';
  static const String startPreparation = 'Start Preparation';
  static const String markReadyForPickup = 'Mark Ready for Pickup';
  static const String orderTime = 'Order Time';
  static const String pickupTime = 'Pickup Time';
  static const String estPrepTime = 'Estimated Prep Time';
  static const String addNote = 'Add Note';
  static const String rejectReason = 'Please provide a reason for rejection:';
  
  static const String noOrders = 'No orders yet';
  static const String ordersEmptyState = 'Orders will appear here when customers place them';
  static const String noHistory = 'No order history';
  static const String historyEmptyState = 'Completed and cancelled orders will appear here';
  
  static const String queue = 'Queue';
  static const String history = 'History';
  
  static const String pickup = 'Pickup: ';
  static const String unknownCustomer = 'Unknown Customer';
  static const String tryAgain = 'Try Again';
  
  static const String orderManagement = 'Order Management';
  // static const String retry = 'Retry'; // Removed duplicate
  static const String welcomeBack = 'Welcome back,';
  static const String todayOrders = "Today's Orders";
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';
  static const String somethingWentWrong = 'Something went wrong';
  static const String noOrdersFound = 'No orders found';
  static const String noMenuItems = 'No menu items yet';
  static const String startAddingMenuItems = 'Add your first menu item to get started';
  static const String addItem = 'Add Item';
  static const String unknownItem = 'Unknown Item';
  static const String active = 'Active';
  static const String hidden = 'Hidden';
  
  static const String confirmDelete = 'Confirm Delete';
  
  static const String available = 'Available';
  static const String unavailable = 'Unavailable';
  static const String hide = 'Hide';
  static const String show = 'Show';
  static const String edit = 'Edit';
  static const String spice = 'Spice: ';
  static const String dietary = 'Dietary: ';
  static const String mins = 'min';
  
  // Statuses
  static const String statusAll = 'All'; // Added
  static const String statusPending = 'Pending';
  static const String statusNewOrder = 'New Order';
  static const String statusConfirmed = 'Confirmed';
  static const String statusAccepted = 'Accepted';
  static const String statusPreparing = 'Preparing';
  static const String statusReady = 'Ready';
  static const String statusReadyForPickup = 'Ready for Pickup';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';
  static const String statusRejected = 'Rejected';
  
  // Filters & Sort
  static const String filters = 'Filters';
  static const String status = 'Status';
  static const String timeRange = 'Time Range';
  static const String timeToday = 'Today';
  static const String timeThisWeek = 'This Week';
  static const String timeThisMonth = 'This Month';
  
  static const String sortBy = 'Sort by:';
  static const String toggleSortOrder = 'Toggle sort order';
  
  static const String sortOrderTime = 'Order Time';
  static const String sortPickupTime = 'Pickup Time';
  static const String sortCustomerName = 'Customer Name';
  static const String sortTotalAmount = 'Total Amount';
  static const String sortPriority = 'Priority';
  static const String sortPrepTime = 'Prep Time';
  
  // Dish Management
  static const String editDish = 'Edit Dish';
  static const String addNewDish = 'Add New Dish';
  static const String savingDish = 'Saving dish...';
  static const String updateDish = 'Update Dish';
  // Add Dish is already AppStrings.addItem? No that's 'Add Item'. 
  static const String addDishAction = 'Add Dish'; 
  
  static const String dishName = 'Dish Name *';
  static const String enterDishName = 'Please enter a dish name';
  static const String shortDescription = 'Short Description';
  static const String shortDescriptionHint = 'Brief description for menu listings';
  static const String detailedDescription = 'Detailed Description';
  static const String detailedDescriptionHint = 'Full description with ingredients, etc.';
  static const String category = 'Category';
  static const String price = 'Price *';
  static const String pricePrefix = 'R'; // South African Rand
  static const String required = 'Required';
  static const String invalid = 'Invalid';
  static const String prepTimeLabel = 'Prep Time (min)';
  static const String spiceLevel = 'Spice Level';
  static const String ingredients = 'Ingredients';
  static const String ingredientsHint = 'Comma-separated';
  static const String allergens = 'Allergens';
  static const String allergensHint = 'Comma-separated';
  static const String dietaryRestrictions = 'Dietary Restrictions';
  static const String featured = 'Featured';
  static const String addDishPhoto = 'Add Dish Photo';
  
  static const String imageSizeError = 'Image size must be less than 5MB';
  static const String imageTypeError = 'Only JPG, PNG, and WebP images are supported';
  static const String imagePickError = 'Error picking image: ';
  static const String photoTakeError = 'Error taking photo: ';
  static const String uploadError = 'Failed to upload image';
  static const String saveError = 'Error saving dish: ';
  
  // Chat
  static const String customerChat = 'Customer Chat';
  static const String messages = 'Messages';
  static const String quickReplies = 'Quick Replies';
  static const String unreadMessages = 'Unread Messages';
  static const String errorLoadingConversations = 'Error loading conversations';
  static const String noConversations = 'No conversations yet';
  static const String noConversationsHint = 'Customer messages will appear here';
  static const String searchConversations = 'Search conversations...';
  static const String noMessages = 'No messages in this conversation yet';
  static const String callCustomer = 'Call Customer';
  static const String noQuickReplies = 'No quick replies yet';
  static const String noQuickRepliesHint = 'Create quick replies for common questions';
  static const String addQuickReply = 'Add Quick Reply';
  static const String editQuickReply = 'Edit Quick Reply';
  static const String title = 'Title';
  static const String titleHint = 'Short title for the reply';
  static const String message = 'Message';
  static const String messageHint = 'The message to send';
  static const String custom = 'Custom';
  static const String add = 'Add';
  static const String update = 'Update';
  // static const String cancel = 'Cancel'; // Removed duplicate
  static const String statusUnread = 'Unread'; // if not already defined
  // Status 'All' already exists as statusAll? Check. Yes.
  
  static const String noConversationsFound = 'No conversations found';
  static const String startConversationHint = 'Start a conversation with customers';
  
  static const String typeMessage = 'Type a message...';
  static const String shareMedia = 'Share Media';
  static const String gallery = 'Gallery';
  static const String camera = 'Camera';
  static const String file = 'File';
  static const String uploading = 'Uploading...';
  static const String sharedFile = 'Shared a file';
  static const String filePickerNotImplemented = 'File picker not implemented yet';
  static const String uploadFileError = 'Failed to upload file: ';
  
  static const String tooltipRemoveFile = 'Remove file';
  static const String tooltipAddMedia = 'Add media';
  static const String tooltipSendMessage = 'Send message';
  
  static const String addReply = 'Add Reply';
  static const String createFirstReply = 'Create Your First Quick Reply';
  static const String repliesSuffix = ' replies';
  // Active/Inactive/Edit/Delete might be duplicated if used elsewhere, but adding here for safety
  // We have 'active'/'hidden' for dishes. Let's use specific ones if needed or generic.
  static const String statusActive = 'Active';
  static const String statusInactive = 'Inactive';
  static const String activate = 'Activate';
  static const String deactivate = 'Deactivate';
  static const String editAction = 'Edit';
  static const String deleteAction = 'Delete';
  
  static const String deleteReplyTitle = 'Delete Quick Reply';
  static const String deleteReplyConfirm = 'Are you sure you want to delete ';
  static const String cannotUndo = '? This action cannot be undone.';
  
  static const String noMessagesStatus = 'No messages';
  static const String unknown = 'Unknown';
  static const String activeNow = 'Active now';
  static const String activeRecently = 'Active recently';
  static const String activeToday = 'Active today';
  static const String inactiveStatus = 'Inactive';
  
  static const String imageMessage = '📷 Image';
  static const String fileMessage = '📎 File';
  static const String locationMessage = '📍 Location';
  
  static const String now = 'now';
  static const String minAgo = 'm ago';
  static const String hourAgo = 'h ago';
  static const String dayAgo = 'd ago';
  static const String noMessagesYet = 'No messages yet';

  // static const String unknownCustomer = 'Unknown Customer'; // Removed duplicate
  
  // Vendor Chat Bloc Errors
  static const String userNotAuthenticated = 'User not authenticated';
  static const String errorLoadingMessages = 'Failed to load messages: ';
  static const String errorSendingMessage = 'Failed to send message: ';
  static const String errorLoadingQuickReplies = 'Failed to load quick replies: ';
  static const String errorCreatingQuickReply = 'Failed to create quick reply: ';
  static const String errorUpdatingQuickReply = 'Failed to update quick reply: ';
  static const String errorDeletingQuickReply = 'Failed to delete quick reply: ';
  static const String errorTogglingQuickReply = 'Failed to toggle quick reply: ';
  
  // Profile Strings
  static const String completeProfile = 'Complete Your Profile';
  static const String setupProfileMessage = 'Set up your profile to start discovering amazing dishes from local chefs';
  static const String createProfile = 'Create Profile';
  static const String memberSince = 'Member since ';
  static const String defaultAddress = 'Default Address';
  static const String quickActions = 'Quick Actions';
  static const String favourites = 'Favourites';
  static const String savedDishes = 'Your saved dishes';
  static const String notifications = 'Notifications';
  static const String managePreferences = 'Manage preferences';
  static const String settings = 'Settings';
  static const String appPreferences = 'App preferences';
  static const String statsOrders = 'Orders';
  static const String statsFavorites = 'Favorites';
  static const String statsReviews = 'Reviews';
  
  // Settings Strings
  static const String account = 'Account';
  static const String notLoggedIn = 'Not logged in';
  static const String manageAccount = 'Manage your account';
  static const String appSettings = 'App Settings';
  static const String manageNotificationPrefs = 'Manage notification preferences';
  static const String language = 'Language';
  static const String english = 'English';
  static const String darkMode = 'Dark Mode';
  static const String enabled = 'Enabled';
  static const String disabled = 'Disabled';
  static const String accountManagement = 'Account Management';
  static const String changePassword = 'Change Password';
  static const String updatePassword = 'Update your password';
  static const String deleteAccount = 'Delete Account';
  static const String delete = 'Delete';
  static const String analytics = 'Analytics';
  static const String deleteAccountSubtitle = 'Permanently delete your account';
  static const String about = 'About';
  static const String appVersionTitle = 'App Version';
  static const String appVersion = '1.0.0';
  static const String privacyPolicy = 'Privacy Policy';
  static const String privacyPolicySubtitle = 'Learn how we protect your data';
  static const String termsOfService = 'Terms of Service';
  static const String termsOfServiceSubtitle = 'Read our terms and conditions';
  static const String helpSupport = 'Help & Support';
  static const String helpSupportSubtitle = 'Get assistance';
  static const String logout = 'Logout';
  static const String logoutConfirmation = 'Are you sure you want to logout?';
  static const String selectLanguage = 'Select Language';
  static const String spanish = 'Spanish';
  static const String french = 'French';
  static const String comingSoon = 'Coming soon';
  static const String currentPassword = 'Current Password';
  static const String newPassword = 'New Password';
  static const String confirmNewPassword = 'Confirm New Password';
  static const String enterCurrentPassword = 'Please enter your current password';
  static const String enterNewPassword = 'Please enter a new password';
  static const String passwordMinLength = 'Password must be at least 6 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String passwordUpdateSuccess = 'Password updated successfully';
  static const String deleteAccountTitle = 'Delete Account';
  static const String deleteAccountConfirmation = 'Are you sure you want to delete your account?';
  static const String deleteAccountWarning = 'This action cannot be undone. All your data will be permanently deleted.';
  static const String deleteAccountNotImplemented = 'Account deletion is not yet implemented';
  
  // Content Strings
  static const String privacyPolicyContent = 'At Chefleet, we take your privacy seriously. This Privacy Policy explains how we collect, use, and protect your personal information.\n\n'
      '1. Information We Collect\n'
      '- Account information (email, name)\n'
      '- Location data (for finding nearby chefs)\n'
      '- Order history and preferences\n\n'
      '2. How We Use Your Information\n'
      '- To process your orders\n'
      '- To connect you with local chefs\n'
      '- To improve our services\n\n'
      '3. Data Protection\n'
      '- We use industry-standard encryption\n'
      '- Your data is never sold to third parties\n'
      '- You can request data deletion at any time';

  static const String termsContent = 'Welcome to Chefleet. By using our services, you agree to these terms.\n\n'
      '1. Service Use\n'
      '- You must be 18+ to use Chefleet\n'
      '- You are responsible for your account security\n'
      '- You agree to provide accurate information\n\n'
      '2. Orders\n'
      '- Orders are binding once confirmed\n'
      '- Payment is cash-only at pickup\n'
      '- Refund policy applies to eligible orders\n\n'
      '3. User Conduct\n'
      '- Be respectful to chefs and other users\n'
      '- Do not misuse the platform\n'
      '- Report any issues to support\n\n'
      '4. Liability\n'
      '- Chefleet connects buyers and sellers\n'
      '- Food safety is the responsibility of vendors\n'
      '- We are not liable for vendor actions';

  static const String helpContentTitle = "Need help? We're here for you!";
  static const String helpEmail = 'Email: support@chefleet.com';
  static const String helpPhone = 'Phone: 1-800-CHEFLEET';
  static const String helpHours = 'Hours: Mon-Fri, 9AM-5PM';
  static const String commonIssues = 'Common Issues:';
  static const String issueOrder = '• Order not showing up';
  static const String issuePayment = '• Cash payment questions';
  static const String issueAccess = '• Account access';
  static const String issueLocation = '• Location services';
  
  // Chat Message Strings
  static const String readStatus = 'Read';
  static const String imageNotAvailable = '[Image not available]';
  static const String failedToLoadImage = 'Failed to load image';
  static const String defaultDocumentName = 'Document';
  static const String tapToDownload = 'Tap to download';
  static const String defaultLocationContent = 'Location shared';
}
