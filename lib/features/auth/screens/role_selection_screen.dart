import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../blocs/auth_bloc.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryGreen,
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 60,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: AppTheme.spacing32),

              // Title
              Text(
                'Choose Your Role',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing12),

              // Subtitle
              Text(
                'Select how you want to use Chefleet',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing32),

              // Role Cards
              _buildRoleCard(
                context,
                role: 'buyer',
                icon: Icons.shopping_bag_outlined,
                title: 'Order Food',
                description: 'Discover and order delicious homemade dishes from local chefs',
                isSelected: _selectedRole == 'buyer',
                onTap: () {
                  setState(() => _selectedRole = 'buyer');
                },
              ),
              const SizedBox(height: AppTheme.spacing16),

              _buildRoleCard(
                context,
                role: 'vendor',
                icon: Icons.store_outlined,
                title: 'Sell Food',
                description: 'Share your culinary creations and earn money as a home chef',
                isSelected: _selectedRole == 'vendor',
                onTap: () {
                  setState(() => _selectedRole = 'vendor');
                },
              ),
              const Spacer(flex: 3),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedRole == null || _isLoading
                      ? null
                      : _handleContinue,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.darkText,
                          ),
                        )
                      : const Text('Continue'),
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Skip Button
              TextButton(
                onPressed: _isLoading ? null : _handleSkip,
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String role,
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.surfaceGreen,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderGreen,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.darkText.withOpacity(0.2)
                    : AppTheme.surfaceGreen,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? AppTheme.darkText : AppTheme.secondaryGreen,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isSelected ? AppTheme.darkText : null,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.darkText.withOpacity(0.8)
                          : AppTheme.secondaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.darkText,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedRole == null) return;

    setState(() => _isLoading = true);

    try {
      // Save role preference to user profile or preferences
      // For now, just navigate based on role
      if (_selectedRole == 'vendor') {
        // Navigate to vendor onboarding
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/vendor/onboarding');
        }
      } else {
        // Navigate to buyer home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/map');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSkip() {
    // Default to buyer role
    Navigator.pushReplacementNamed(context, '/map');
  }
}
