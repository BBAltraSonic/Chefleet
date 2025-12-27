import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class QuickReplyWidget extends StatelessWidget {
  final List<Map<String, dynamic>> quickReplies;
  final Map<String, List<Map<String, dynamic>>> groupedQuickReplies;
  final VoidCallback onAddQuickReply;
  final Function(Map<String, dynamic>) onEditQuickReply;
  final Function(String) onDeleteQuickReply;
  final Function(String, bool) onToggleQuickReply;

  const QuickReplyWidget({
    super.key,
    required this.quickReplies,
    required this.groupedQuickReplies,
    required this.onAddQuickReply,
    required this.onEditQuickReply,
    required this.onDeleteQuickReply,
    required this.onToggleQuickReply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${AppStrings.quickReplies} (${quickReplies.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAddQuickReply,
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.addReply),
              ),
            ],
          ),
        ),

        // Quick Replies List
        Expanded(
          child: groupedQuickReplies.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedQuickReplies.keys.length,
                  itemBuilder: (context, index) {
                    final category = groupedQuickReplies.keys.elementAt(index);
                    final replies = groupedQuickReplies[category] ?? [];

                    return _buildCategorySection(context, category, replies);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flash_on_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noQuickReplies,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noQuickRepliesHint,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddQuickReply,
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.createFirstReply),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<Map<String, dynamic>> replies,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category),
                  color: _getCategoryColor(category),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(category),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${replies.length}${AppStrings.repliesSuffix}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getCategoryColor(category),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quick Replies List
          ...replies.asMap().entries.map((entry) {
            final index = entry.key;
            final quickReply = entry.value;

            return Column(
              children: [
                if (index > 0)
                  const Divider(height: 1),
                _buildQuickReplyTile(context, quickReply),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickReplyTile(BuildContext context, Map<String, dynamic> quickReply) {
    final title = quickReply['title'] as String? ?? '';
    final content = quickReply['content'] as String? ?? '';
    final isActive = quickReply['is_active'] as bool? ?? true;
    final sortOrder = quickReply['sort_order'] as int? ?? 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
        child: Text(
          (sortOrder + 1).toString(),
          style: TextStyle(
            color: isActive
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: isActive ? null : Theme.of(context).colorScheme.outline,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isActive ? null : Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isActive ? Icons.visibility : Icons.visibility_off,
                size: 12,
                color: isActive
                    ? Colors.green
                    : Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                isActive ? AppStrings.statusActive : AppStrings.statusInactive,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive ? Colors.green : Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEditQuickReply(quickReply);
              break;
            case 'toggle':
              onToggleQuickReply(quickReply['id'] as String? ?? '', !isActive);
              break;
            case 'delete':
              _showDeleteConfirmation(context, quickReply);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit, size: 16),
                const SizedBox(width: 8),
                const Text(AppStrings.editAction),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'toggle',
            child: Row(
              children: [
                Icon(
                  isActive ? Icons.visibility_off : Icons.visibility,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(isActive ? AppStrings.deactivate : AppStrings.activate),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                const Text(AppStrings.deleteAction, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      onTap: () => onEditQuickReply(quickReply),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> quickReply) {
    final title = quickReply['title'] as String? ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteReplyTitle),
        content: Text('${AppStrings.deleteReplyConfirm}"$title"${AppStrings.cannotUndo}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteQuickReply(quickReply['id'] as String? ?? '');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.deleteAction),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'greeting':
        return Colors.green;
      case 'order status':
        return Colors.blue;
      case 'preparation time':
        return Colors.orange;
      case 'payment':
      case 'cash payment':
        return Colors.purple;
      case 'location':
        return Colors.red;
      case 'menu':
        return Colors.indigo;
      case 'common questions':
        return Colors.teal;
      case 'closing':
        return Colors.grey;
      default:
        return Colors.brown;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'greeting':
        return Icons.waving_hand;
      case 'order status':
        return Icons.receipt_long;
      case 'preparation time':
        return Icons.schedule;
      case 'payment':
      case 'cash payment':
        return Icons.payments_outlined;
      case 'location':
        return Icons.location_on;
      case 'menu':
        return Icons.restaurant_menu;
      case 'common questions':
        return Icons.help_outline;
      case 'closing':
        return Icons.check_circle;
      default:
        return Icons.chat;
    }
  }
}