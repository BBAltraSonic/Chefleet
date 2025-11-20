import 'package:flutter/material.dart';

/*
 * Legacy OfflineBanner implementation that was tightly coupled to a demo
 * connectivity BLoC. It is kept here for reference but commented out to
 * avoid compilation issues and unnecessary dependencies while the app moves
 * to a simpler offline indicator.
 *
 * The new implementation lives below this block comment.
 *
 * BEGIN LEGACY IMPLEMENTATION

/// A prominent offline banner that shows when the app is offline
class _LegacyOfflineBanner extends StatelessWidget {
  const _LegacyOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget _buildOfflineBanner(BuildContext context, ConnectivityState state) {
    final isRestoring = state is ConnectivityRestoring;
    final message = isRestoring
        ? 'Reconnecting...'
        : 'You\'re offline. Showing cached data.';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isRestoring
                ? [Colors.orange.shade400, Colors.orange.shade600]
                : [Colors.red.shade400, Colors.red.shade600],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isRestoring) ...[
              _buildLoadingIndicator(),
              const SizedBox(width: 12),
            ] else ...[
              Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!isRestoring) ...[
              _buildRefreshButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showRefreshOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'Refresh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRefreshOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRefreshOptionsSheet(context),
    );
  }

  Widget _buildRefreshOptionsSheet(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.wifi_off,
                    size: 48,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'You\'re Offline',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Showing cached data from your last sync. Some features may be limited.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOptionTile(
                    context,
                    icon: Icons.refresh,
                    title: 'Try Again',
                    subtitle: 'Check for internet connection',
                    onTap: () {
                      Navigator.pop(context);
                      // Trigger connectivity check
                      context.read<ConnectivityBloc>().add(CheckConnectivityRequested());
                    },
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    context,
                    icon: Icons.settings,
                    title: 'Network Settings',
                    subtitle: 'Open device network settings',
                    onTap: () {
                      Navigator.pop(context);
                      // Open network settings
                      // This would need platform-specific implementation
                    },
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'Learn More',
                    subtitle: 'About offline mode',
                    onTap: () {
                      Navigator.pop(context);
                      _showOfflineModeInfo(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: Icon(
          icon,
          color: Colors.grey.shade700,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  void _showOfflineModeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Mode'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'While offline, you can:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            _buildFeatureItem('✓ View cached vendor information'),
            _buildFeatureItem('✓ Browse previously loaded dishes'),
            _buildFeatureItem('✓ See cached map data'),
            _buildFeatureItem('✗ Place new orders'),
            _buildFeatureItem('✗ Get real-time updates'),
            SizedBox(height: 16),
            Text(
              'Your data will sync automatically when you reconnect.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

/// Simple connectivity bloc for demonstration
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  ConnectivityBloc() : super(ConnectivityInitial()) {
    on<CheckConnectivityRequested>(_onCheckConnectivity);
  }

  Future<void> _onCheckConnectivity(
    CheckConnectivityRequested event,
    Emitter<ConnectivityState> emit,
  ) async {
    emit(ConnectivityRestoring());

    // Simulate connectivity check
    await Future.delayed(const Duration(seconds: 2));

    // For demo purposes, we'll stay offline
    emit(const ConnectivityOffline());
  }
}

abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class CheckConnectivityRequested extends ConnectivityEvent {}

abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object> get props => [];
}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivityOnline extends ConnectivityState {}

class ConnectivityOffline extends ConnectivityState {}

class ConnectivityRestoring extends ConnectivityState {}

extension EquatableExtension on Object {
  List<Object> get props => [];
}

*/

/// Lightweight, self-contained offline banner used by the feed and map
/// experiences. It does not depend on any BLoC – callers decide when to
/// show it and can optionally wire a retry callback.
class OfflineBanner extends StatelessWidget {
  final VoidCallback? onRetry;

  const OfflineBanner({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container
      (
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "You're offline. Showing cached data.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}