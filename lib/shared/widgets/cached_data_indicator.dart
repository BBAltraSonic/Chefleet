import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget that displays information about cached data
class CachedDataIndicator extends StatelessWidget {
  final DateTime? lastUpdated;
  final int vendorCount;
  final int dishCount;
  final VoidCallback? onRefresh;
  final bool isOffline;

  const CachedDataIndicator({
    super.key,
    this.lastUpdated,
    required this.vendorCount,
    required this.dishCount,
    this.onRefresh,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    if (lastUpdated == null && vendorCount == 0 && dishCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOffline ? Colors.orange.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOffline ? Colors.orange.shade200 : Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          _buildContent(context),
          if (onRefresh != null) ...[
            const SizedBox(height: 12),
            _buildRefreshButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOffline ? Colors.orange.shade100 : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isOffline ? Icons.offline_bolt : Icons.cached,
            color: isOffline ? Colors.orange.shade700 : Colors.blue.shade700,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOffline ? 'Offline Mode' : 'Cached Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOffline ? Colors.orange.shade900 : Colors.blue.shade900,
                ),
              ),
              if (lastUpdated != null)
                Text(
                  _formatLastUpdated(lastUpdated!),
                  style: TextStyle(
                    fontSize: 12,
                    color: isOffline ? Colors.orange.shade700 : Colors.blue.shade700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildDataRow(
            icon: Icons.store,
            label: 'Vendors',
            value: vendorCount.toString(),
            color: isOffline ? Colors.orange : Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildDataRow(
            icon: Icons.restaurant,
            label: 'Dishes',
            value: dishCount.toString(),
            color: isOffline ? Colors.orange : Colors.blue,
          ),
          if (isOffline) ...[
            const SizedBox(height: 8),
            _buildDataRow(
              icon: Icons.info_outline,
              label: 'Status',
              value: 'Limited functionality',
              color: Colors.grey,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataRow({
    required IconData icon,
    required String label,
    required String value,
    required MaterialColor color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color.shade700,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh, size: 18),
        label: Text(
          isOffline ? 'Try to Connect' : 'Refresh Data',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOffline ? Colors.orange.shade600 : Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Last updated ${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return 'Last updated ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return 'Last updated ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Last updated just now';
    }
  }
}

/// Widget for displaying cache statistics
class CacheStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;
  final VoidCallback? onClearCache;

  const CacheStatsWidget({
    super.key,
    required this.stats,
    this.onClearCache,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storage,
                color: Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Cache Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const Spacer(),
              if (onClearCache != null)
                IconButton(
                  onPressed: onClearCache,
                  icon: Icon(
                    Icons.clear_all,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  tooltip: 'Clear Cache',
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatRow('Cache Size', _formatBytes(stats['sizeBytes'] ?? 0)),
          _buildStatRow('Last Updated', _formatTimestamp(stats['lastUpdated'])),
          _buildStatRow('Version', 'v${stats['version'] ?? '1'}'),
          if (stats['vendors'] != null)
            _buildStatRow('Cached Vendors', '${stats['vendors']}'),
          if (stats['dishes'] != null)
            _buildStatRow('Cached Dishes', '${stats['dishes']}'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }
}