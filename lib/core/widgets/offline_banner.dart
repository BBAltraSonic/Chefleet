import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/role_bloc.dart';
import '../blocs/role_state.dart';
import '../blocs/role_event.dart';

/// Banner that displays when the app is in offline mode.
///
/// Shows:
/// - Offline indicator icon
/// - Message explaining offline mode
/// - Retry button to attempt reconnection
///
/// The banner animates in/out smoothly when offline state changes.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, roleState) {
        final isOffline = roleState is RoleLoaded && roleState.isOffline;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isOffline ? 40 : 0,
          child: isOffline
              ? _buildBannerContent(context)
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildBannerContent(BuildContext context) {
    return Container(
      color: Colors.orange.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Offline mode - Changes will sync when online',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<RoleBloc>().add(const RoleRefreshRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
