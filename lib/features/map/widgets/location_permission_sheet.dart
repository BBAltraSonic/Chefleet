import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_theme.dart' show AppTheme;
import '../../../shared/widgets/glass_container.dart';

class LocationPermissionSheet extends StatelessWidget {
  const LocationPermissionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) => const LocationPermissionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: AppTheme.radiusXLarge.toDouble(),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceGreen,
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 50,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Title
            Text(
              'Enable Location Services',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing12),

            // Description
            Text(
              'We need your location to show nearby home chefs and provide accurate delivery estimates.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing32),

            // Benefits List
            _buildBenefit(
              context,
              icon: Icons.near_me,
              text: 'Find chefs near you',
            ),
            const SizedBox(height: AppTheme.spacing12),
            _buildBenefit(
              context,
              icon: Icons.access_time,
              text: 'Get accurate delivery times',
            ),
            const SizedBox(height: AppTheme.spacing12),
            _buildBenefit(
              context,
              icon: Icons.local_shipping_outlined,
              text: 'Track your order in real-time',
            ),
            const SizedBox(height: AppTheme.spacing32),

            // Allow Location Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleAllowLocation(context),
                child: const Text('Allow Location'),
              ),
            ),
            const SizedBox(height: AppTheme.spacing12),

            // Not Now Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Not Now'),
              ),
            ),
            const SizedBox(height: AppTheme.spacing8),

            // Privacy Note
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
              ),
              child: Text(
                'We respect your privacy. Location data is only used to enhance your experience.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryGreen,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.surfaceGreen,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(
            icon,
            color: AppTheme.darkText,
            size: 20,
          ),
        ),
        const SizedBox(width: AppTheme.spacing16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleAllowLocation(BuildContext context) async {
    final status = await Permission.location.request();

    if (!context.mounted) return;

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location access granted'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location access denied'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, false);
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(context);
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text(
          'Location permission is permanently denied. Please enable it in app settings to use location features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
