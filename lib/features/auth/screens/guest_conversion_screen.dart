import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/guest_conversion_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../blocs/auth_bloc.dart';

/// Screen for converting guest accounts to registered user accounts
/// 
/// Displays benefits of registration and handles the conversion flow
class GuestConversionScreen extends StatefulWidget {
  const GuestConversionScreen({
    super.key,
    this.guestId,
    this.stats,
    this.onSkip,
  });

  final String? guestId;
  final GuestSessionStats? stats;
  final VoidCallback? onSkip;

  @override
  State<GuestConversionScreen> createState() => _GuestConversionScreenState();
}

class _GuestConversionScreenState extends State<GuestConversionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleConversion() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authBloc = context.read<AuthBloc>();
    authBloc.add(AuthGuestToRegisteredRequested(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.mode == AuthMode.authenticated) {
          // Conversion successful, navigate away
          Navigator.of(context).pop(true);
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
        setState(() {
          _isLoading = state.isLoading;
        });
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.darkText),
                  onPressed: widget.onSkip ?? () => Navigator.of(context).pop(),
                ),
                actions: [
                  if (widget.onSkip != null)
                    TextButton(
                      onPressed: widget.onSkip,
                      child: Text(
                        'Skip',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.secondaryGreen,
                            ),
                      ),
                    ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header
                    _buildHeader(),
                    const SizedBox(height: AppTheme.spacing32),

                    // Benefits
                    _buildBenefits(),
                    const SizedBox(height: AppTheme.spacing32),

                    // Stats (if available)
                    if (widget.stats != null && widget.stats!.hasActivity) ...[
                      _buildStats(),
                      const SizedBox(height: AppTheme.spacing32),
                    ],

                    // Form
                    _buildForm(),
                    const SizedBox(height: AppTheme.spacing24),

                    // Submit Button
                    _buildSubmitButton(),
                    const SizedBox(height: AppTheme.spacing16),

                    // Terms
                    _buildTerms(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: const Icon(
            Icons.account_circle_outlined,
            size: 48,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: AppTheme.spacing20),
        Text(
          'Create Your Account',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: AppTheme.spacing12),
        Text(
          'Save your progress and unlock more features by creating a free account.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.secondaryGreen,
              ),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    return GlassContainer(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      borderRadius: AppTheme.radiusLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benefits',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacing16),
          _buildBenefitItem(
            icon: Icons.bookmark_outline,
            title: 'Save Your Orders',
            description: 'Access your order history anytime',
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildBenefitItem(
            icon: Icons.chat_bubble_outline,
            title: 'Continue Conversations',
            description: 'Keep chatting with vendors',
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildBenefitItem(
            icon: Icons.favorite_outline,
            title: 'Save Favorites',
            description: 'Bookmark your favorite dishes',
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildBenefitItem(
            icon: Icons.notifications_outlined,
            title: 'Get Notifications',
            description: 'Stay updated on your orders',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final stats = widget.stats!;
    return GlassContainer(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      borderRadius: AppTheme.radiusLarge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Row(
            children: [
              if (stats.orderCount > 0)
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.shopping_bag_outlined,
                    value: stats.orderCount.toString(),
                    label: stats.orderCount == 1 ? 'Order' : 'Orders',
                  ),
                ),
              if (stats.orderCount > 0 && stats.messageCount > 0)
                const SizedBox(width: AppTheme.spacing12),
              if (stats.messageCount > 0)
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.chat_bubble_outline,
                    value: stats.messageCount.toString(),
                    label: stats.messageCount == 1 ? 'Message' : 'Messages',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGreen,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 24),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryGreen,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleConversion(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleConversion,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Create Account',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
      ),
    );
  }

  Widget _buildTerms() {
    return Text(
      'By creating an account, you agree to our Terms of Service and Privacy Policy.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
          ),
      textAlign: TextAlign.center,
    );
  }
}
