import 'package:flutter/material.dart';
import 'glass_container.dart';
import 'shimmer.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({
    super.key,
    this.message = 'Loading...',
    this.showProgress = true,
  });

  final String message;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        width: 200,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
              ],
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.showIcon = true,
  });

  final String error;
  final VoidCallback? onRetry;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showIcon) ...[
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.action,
  });

  final String message;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassContainer(
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 48,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (action != null) ...[
                const SizedBox(height: 16),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({
    super.key,
    required this.isConnected,
    required this.onRetry,
  });

  final bool isConnected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red,
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'No internet connection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

class OrderLoadingWidget extends StatelessWidget {
  const OrderLoadingWidget({
    super.key,
    this.message = 'Placing Order...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: GlassContainer(
          width: 250,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}