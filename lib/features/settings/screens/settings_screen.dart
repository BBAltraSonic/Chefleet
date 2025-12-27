import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/blocs/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/blocs/theme_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          children: [
            // Profile Section
            GlassContainer(
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
            ),
            const SizedBox(height: AppTheme.spacing16),

            // App Settings Section
            GlassContainer(
              borderRadius: AppTheme.radiusLarge,
              blur: 12,
              opacity: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Text(
                      AppStrings.appSettings,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const Divider(height: 1, indent: 64),
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
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Account Management Section
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (!state.isAuthenticated) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    GlassContainer(
                      borderRadius: AppTheme.radiusLarge,
                      blur: 12,
                      opacity: 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppTheme.spacing16),
                            child: Text(
                              AppStrings.accountManagement,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          const Divider(height: 1, indent: 64),
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
                    ),
                    const SizedBox(height: AppTheme.spacing16),
                  ],
                );
              },
            ),

            // About Section
            GlassContainer(
              borderRadius: AppTheme.radiusLarge,
              blur: 12,
              opacity: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: Text(
                      AppStrings.about,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const Divider(height: 1, indent: 64),
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
            ),
            const SizedBox(height: AppTheme.spacing16),

            // Logout Button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state.isAuthenticated) {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        AppStrings.logout,
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: AppTheme.spacing24),
          ],
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
              context.read<AuthBloc>().add(const AuthLogoutRequested());
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
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.privacyPolicy),
        content: const SingleChildScrollView(
          child: Text(
            AppStrings.privacyPolicyContent,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.termsOfService),
        content: const SingleChildScrollView(
          child: Text(
            AppStrings.termsContent,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(AppStrings.english),
              trailing: const Icon(Icons.check, color: AppTheme.primaryGreen),
              onTap: () => Navigator.of(context).pop(),
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
            onPressed: () => Navigator.of(context).pop(),
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
                  await context.read<AuthBloc>().updatePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                  
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.passwordUpdateSuccess),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
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
              ScaffoldMessenger.of(context).showSnackBar(
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