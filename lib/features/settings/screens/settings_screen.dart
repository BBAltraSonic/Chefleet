import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/blocs/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/blocs/theme_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryGreen.withOpacity(0.2),
                      AppTheme.backgroundColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacing24,
                      AppTheme.spacing32,
                      AppTheme.spacing24,
                      AppTheme.spacing16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          AppStrings.settings,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          'Personalize your experience',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.spacing8),
                      
                      // User Profile Card
                      _buildUserProfileCard(context),
                      const SizedBox(height: AppTheme.spacing24),

                      // Preferences Section
                      _buildSectionHeader(context, 'Preferences', Icons.tune_outlined),
                      const SizedBox(height: AppTheme.spacing12),
                      _buildPreferencesSection(context),
                      const SizedBox(height: AppTheme.spacing24),

                      // Account Security Section
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (!state.isAuthenticated) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(context, 'Security', Icons.security_outlined),
                              const SizedBox(height: AppTheme.spacing12),
                              _buildSecuritySection(context),
                              const SizedBox(height: AppTheme.spacing24),
                            ],
                          );
                        },
                      ),

                      // Support & Legal Section
                      _buildSectionHeader(context, 'Support & Legal', Icons.support_agent_outlined),
                      const SizedBox(height: AppTheme.spacing12),
                      _buildSupportSection(context),
                      const SizedBox(height: AppTheme.spacing32),

                      // Logout Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (!state.isAuthenticated) return const SizedBox.shrink();
                          return _buildLogoutButton(context);
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing24),

                      // App Version Footer
                      _buildVersionFooter(context),
                      const SizedBox(height: AppTheme.spacing32),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context) {
    return GlassContainer(
      borderRadius: AppTheme.radiusLarge,
      blur: 12,
      opacity: 0.6,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.account,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppTheme.spacing16),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state.user == null) {
                return const Text(AppStrings.notLoggedIn);
              }
              return Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceGreen,
                      border: Border.all(
                        color: AppTheme.primaryGreen,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        state.user!.email?.substring(0, 1).toUpperCase() ?? 'U',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.user!.email ?? '',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.manageAccount,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 24),
        const SizedBox(width: AppTheme.spacing8),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return GlassContainer(
      borderRadius: AppTheme.radiusLarge,
      blur: 12,
      opacity: 0.6,
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.notifications_outlined,
            title: AppStrings.notifications,
            subtitle: AppStrings.manageNotificationPrefs,
            onTap: () => context.push(CustomerRoutes.notifications),
          ),
          const Divider(height: 1, indent: 64),
          _buildSettingsTile(
            context,
            icon: Icons.language_outlined,
            title: AppStrings.language,
            subtitle: AppStrings.english,
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(height: 1, indent: 64),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return _buildSettingsTileWithSwitch(
                context,
                icon: Icons.dark_mode_outlined,
                title: AppStrings.darkMode,
                subtitle: themeState.isDarkMode ? AppStrings.enabled : AppStrings.disabled,
                value: themeState.isDarkMode,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(const ThemeToggled());
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return GlassContainer(
      borderRadius: AppTheme.radiusLarge,
      blur: 12,
      opacity: 0.6,
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline,
            title: AppStrings.changePassword,
            subtitle: AppStrings.updatePassword,
            onTap: () => _showChangePasswordDialog(context),
          ),
          const Divider(height: 1, indent: 64),
          _buildSettingsTile(
            context,
            icon: Icons.delete_outline,
            title: AppStrings.deleteAccount,
            subtitle: AppStrings.deleteAccountSubtitle,
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return GlassContainer(
      borderRadius: AppTheme.radiusLarge,
      blur: 12,
      opacity: 0.6,
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: AppStrings.appVersionTitle,
            subtitle: AppStrings.appVersion,
            onTap: null,
          ),
          const Divider(height: 1, indent: 64),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: AppStrings.privacyPolicy,
            subtitle: AppStrings.privacyPolicySubtitle,
            onTap: () {
              _showPrivacyPolicy(context);
            },
          ),
          const Divider(height: 1, indent: 64),
          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: AppStrings.termsOfService,
            subtitle: AppStrings.termsOfServiceSubtitle,
            onTap: () {
              _showTermsOfService(context);
            },
          ),
          const Divider(height: 1, indent: 64),
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: AppStrings.helpSupport,
            subtitle: AppStrings.helpSupportSubtitle,
            onTap: () {
              _showHelp(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: Colors.red.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 24),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                AppStrings.logout,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionFooter(BuildContext context) {
    return Center(
      child: Text(
        AppStrings.appVersion,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.secondaryGreen.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right,
                color: AppTheme.secondaryGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTileWithSwitch(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryGreen,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // Capture bloc reference before showing dialog
    final authBloc = context.read<AuthBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              authBloc.add(const AuthLogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.privacyPolicy),
        content: const SingleChildScrollView(
          child: Text(
            AppStrings.privacyPolicyContent,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.termsOfService),
        content: const SingleChildScrollView(
          child: Text(
            AppStrings.termsContent,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.helpSupport),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.helpContentTitle,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text(AppStrings.helpEmail),
            SizedBox(height: 8),
            Text(AppStrings.helpPhone),
            SizedBox(height: 8),
            Text(AppStrings.helpHours),
            SizedBox(height: 16),
            Text(
              AppStrings.commonIssues,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(AppStrings.issueOrder),
            Text(AppStrings.issuePayment),
            Text(AppStrings.issueAccess),
            Text(AppStrings.issueLocation),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(AppStrings.english),
              trailing: const Icon(Icons.check, color: AppTheme.primaryGreen),
              onTap: () => Navigator.of(dialogContext).pop(),
            ),
            ListTile(
              title: const Text(AppStrings.spanish),
              subtitle: const Text(AppStrings.comingSoon),
              enabled: false,
              onTap: () {},
            ),
            ListTile(
              title: const Text(AppStrings.french),
              subtitle: const Text(AppStrings.comingSoon),
              enabled: false,
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    // Capture bloc and messenger references before showing dialog
    final authBloc = context.read<AuthBloc>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.changePassword),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.currentPassword,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterCurrentPassword;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.newPassword,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterNewPassword;
                  }
                  if (value.length < 6) {
                    return AppStrings.passwordMinLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.confirmNewPassword,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return AppStrings.passwordMismatch;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  // Update password using Supabase
                  await authBloc.updatePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                  
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.passwordUpdateSuccess),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text(AppStrings.update),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    // Capture messenger reference before showing dialog
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteAccountTitle),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.deleteAccountConfirmation,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(AppStrings.deleteAccountWarning),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.of(dialogContext).pop();
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.deleteAccountNotImplemented),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.deleteAction),
          ),
        ],
      ),
    );
  }
}