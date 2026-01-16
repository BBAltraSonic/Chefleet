import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/auth_error_display.dart';
import '../models/auth_error_type.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/blocs/role_bloc.dart';
import '../../../core/blocs/role_event.dart';
import '../../../core/models/user_role.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  
  String? _selectedSignupRole;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chefleet',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover delicious food nearby',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Auth Forms
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Login'),
                            Tab(text: 'Sign Up'),
                          ],
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 500,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildLoginForm(context),
                              _buildSignupForm(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Guest Mode Button
                  _buildGuestModeButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Form(
          key: _loginFormKey,
          child: Column(
            children: [
              if (state.errorMessage != null || state.errorType != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AuthErrorDisplay(
                    type: state.errorType ?? AuthErrorType.unknown,
                    customMessage: state.errorMessage,
                    onDismiss: () => context.read<AuthBloc>().add(const AuthErrorOccurred('')),
                    onRetry: () {
                       context.read<AuthBloc>().add(const AuthErrorOccurred(''));
                       _handleLogin(context);
                    },
                    onSecondaryAction: () => context.push('/forgot-password'),
                  ),
                ),
              TextFormField(
                controller: _loginEmailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !state.isLoading,
                onChanged: (_) {
                  if (state.errorMessage != null) {
                    context.read<AuthBloc>().add(const AuthErrorOccurred(''));
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _loginPasswordController,
                obscureText: true,
                enabled: !state.isLoading,
                onChanged: (_) {
                  if (state.errorMessage != null) {
                    context.read<AuthBloc>().add(const AuthErrorOccurred(''));
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: state.isLoading ? null : () => context.push('/forgot-password'),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (state.isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Signing you in...",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : () => _handleLogin(context),
                  child: state.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 24),
              // Social Login Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: state.isLoading ? null : () {
                    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
                  },
                  icon: Icon(
                    Icons.g_mobiledata,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Form(
          key: _signupFormKey,
          child: Column(
            children: [
              if (state.errorMessage != null || state.errorType != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AuthErrorDisplay(
                    type: state.errorType ?? AuthErrorType.unknown,
                    customMessage: state.errorMessage,
                    onDismiss: () => context.read<AuthBloc>().add(const AuthErrorOccurred('')),
                    onRetry: () {
                       context.read<AuthBloc>().add(const AuthErrorOccurred(''));
                       _handleSignup(context);
                    },
                    onSecondaryAction: state.errorType == AuthErrorType.emailExists 
                        ? () {
                            // Clear error and switch to login tab
                            context.read<AuthBloc>().add(const AuthErrorOccurred(''));
                            _tabController.animateTo(0);
                            // Pre-fill email in login form
                            _loginEmailController.text = _signupEmailController.text;
                          }
                        : null,
                  ),
                ),
              TextFormField(
                controller: _signupNameController,
                enabled: !state.isLoading,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _signupEmailController,
                keyboardType: TextInputType.emailAddress,
                enabled: !state.isLoading,
                onChanged: (value) {
                   if (state.errorMessage != null) {
                     context.read<AuthBloc>().add(const AuthErrorOccurred(''));
                   }
                   setState(() {});
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                  suffixIcon: _signupEmailController.text.contains('@') && _signupEmailController.text.contains('.')
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _signupPasswordController,
                obscureText: true,
                enabled: !state.isLoading,
                onChanged: (value) {
                   if (state.errorMessage != null) {
                     context.read<AuthBloc>().add(const AuthErrorOccurred(''));
                   }
                   setState(() {});
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  border: const OutlineInputBorder(),
                  helperText: _signupPasswordController.text.isNotEmpty 
                      ? 'At least 6 characters (${_signupPasswordController.text.length}/6)'
                      : null,
                  helperStyle: TextStyle(
                    color: _signupPasswordController.text.length >= 6 ? Colors.green : Colors.grey,
                  ),
                ),
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
              const SizedBox(height: 16),
              Text(
                'What brings you to Chefleet?',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Order Food'),
                      selected: _selectedSignupRole == 'customer',
                      onSelected: state.isLoading ? null : (selected) {
                        setState(() => _selectedSignupRole = selected ? 'customer' : null);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Sell Food'),
                      selected: _selectedSignupRole == 'vendor',
                      onSelected: state.isLoading ? null : (selected) {
                        setState(() => _selectedSignupRole = selected ? 'vendor' : null);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (state.isLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Creating your account...",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (state.isLoading || _selectedSignupRole == null) ? null : () => _handleSignup(context),
                  child: state.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Sign Up'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogin(BuildContext context) {
    if (_loginFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              _loginEmailController.text.trim(),
              _loginPasswordController.text,
            ),
          );
    }
  }

  void _handleSignup(BuildContext context) {
    if (_signupFormKey.currentState!.validate() && _selectedSignupRole != null) {
      context.read<AuthBloc>().add(
            AuthSignupRequested(
              _signupEmailController.text.trim(),
              _signupPasswordController.text,
              _signupNameController.text.trim(),
              initialRole: _selectedSignupRole,
            ),
          );
    }
  }

  Widget _buildGuestModeButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppTheme.borderGreen.withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.secondaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppTheme.borderGreen.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => _handleGuestMode(context),
                  icon: const Icon(
                    Icons.person_outline,
                    size: 20,
                  ),
                  label: const Text('Continue as Guest'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: AppTheme.primaryGreen.withOpacity(0.5),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Browse and order without creating an account',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryGreen,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleGuestMode(BuildContext context) {
    // Start guest mode
    context.read<AuthBloc>().add(const AuthGuestModeStarted());
    
    // Navigate to map feed
    context.go(CustomerRoutes.map);
  }
}