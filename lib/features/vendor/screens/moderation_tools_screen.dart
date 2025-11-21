import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_container.dart';

class ModerationToolsScreen extends StatelessWidget {
  const ModerationToolsScreen({super.key});

  // Feature flag - set to false in production
  static const bool _isModerationEnabled = false;

  @override
  Widget build(BuildContext context) {
    // Feature flag guard
    if (!_isModerationEnabled) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Moderation Tools'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: AppTheme.secondaryGreen,
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  'Feature Not Available',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Moderation tools are currently disabled. Please contact support for access.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.secondaryGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation Tools'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        children: [
          _buildToolCard(
            context,
            icon: Icons.report_problem_outlined,
            title: 'Reported Issues',
            description: 'View and manage reported issues from customers.',
            onTap: () {
              // TODO: Navigate to reported issues
            },
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildToolCard(
            context,
            icon: Icons.block_outlined,
            title: 'Blocked Customers',
            description: 'Manage blocked customers and restrictions.',
            onTap: () {
              // TODO: Navigate to blocked list
            },
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildToolCard(
            context,
            icon: Icons.rate_review_outlined,
            title: 'Review Moderation',
            description: 'Flag inappropriate reviews for platform admin.',
            onTap: () {
              // TODO: Navigate to reviews
            },
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildToolCard(
            context,
            icon: Icons.policy_outlined,
            title: 'Platform Guidelines',
            description: 'View platform selling guidelines and policies.',
            onTap: () {
              // TODO: Show guidelines
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
