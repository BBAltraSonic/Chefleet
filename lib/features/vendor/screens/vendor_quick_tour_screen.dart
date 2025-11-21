import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';

class VendorQuickTourScreen extends StatefulWidget {
  const VendorQuickTourScreen({super.key});

  @override
  State<VendorQuickTourScreen> createState() => _VendorQuickTourScreenState();
}

class _VendorQuickTourScreenState extends State<VendorQuickTourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TourStep> _tourSteps = [
    TourStep(
      icon: Icons.dashboard_outlined,
      title: 'Welcome to Your Dashboard',
      description: 'Your central hub for managing orders, menu items, and tracking your business performance.',
      color: AppTheme.primaryGreen,
    ),
    TourStep(
      icon: Icons.receipt_long_outlined,
      title: 'Manage Orders',
      description: 'Accept, prepare, and complete orders. Use status filters to organize your queue efficiently.',
      color: Colors.blue,
    ),
    TourStep(
      icon: Icons.restaurant_menu_outlined,
      title: 'Update Your Menu',
      description: 'Add new dishes, edit existing items, and manage availability in real-time.',
      color: Colors.orange,
    ),
    TourStep(
      icon: Icons.qr_code_2_outlined,
      title: 'Pickup Code Verification',
      description: 'Verify pickup codes to complete orders securely. Customers will show you their unique code.',
      color: Colors.purple,
    ),
    TourStep(
      icon: Icons.chat_bubble_outline,
      title: 'Customer Communication',
      description: 'Chat with customers about their orders. Quick replies help you respond faster.',
      color: Colors.green,
    ),
    TourStep(
      icon: Icons.analytics_outlined,
      title: 'Track Performance',
      description: 'Monitor your daily, weekly, and monthly stats to grow your business.',
      color: Colors.indigo,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _tourSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTour();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeTour() {
    // Mark tour as completed in preferences
    // TODO: Save completion state to shared preferences or user profile
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Quick Tour'),
        actions: [
          TextButton(
            onPressed: _completeTour,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                children: List.generate(
                  _tourSteps.length,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < _tourSteps.length - 1 ? 8 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppTheme.primaryGreen
                            : AppTheme.borderGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Tour content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _tourSteps.length,
                itemBuilder: (context, index) {
                  return _buildTourPage(_tourSteps[index]);
                },
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    flex: _currentPage == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentPage == _tourSteps.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourPage(TourStep step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Icon
          GlassContainer(
            padding: const EdgeInsets.all(AppTheme.spacing32),
            borderRadius: AppTheme.radiusXLarge,
            color: step.color,
            opacity: 0.1,
            child: Icon(
              step.icon,
              size: 80,
              color: step.color,
            ),
          ),

          const SizedBox(height: AppTheme.spacing32),

          // Title
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.darkText,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Description
          Text(
            step.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.secondaryGreen,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class TourStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  TourStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
