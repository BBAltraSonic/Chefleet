import 'package:flutter/material.dart';
import '../blocs/vendor_chat_bloc.dart';
import '../../../../core/constants/app_strings.dart';

class ChatMessageWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isFromVendor;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isFromVendor,
  });

  @override
  Widget build(BuildContext context) {
    final content = message['content'] as String? ?? '';
    final messageType = VendorChatState.getMessageType(message);
    final createdAt = DateTime.tryParse(message['created_at'] ?? '') ?? DateTime.now();
    final isRead = message['is_read'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isFromVendor ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isFromVendor) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.person,
                size: 16,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isFromVendor ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isFromVendor
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isFromVendor ? const Radius.circular(16) : Radius.zero,
                      bottomRight: isFromVendor ? Radius.zero : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message content based on type
                      if (messageType == 'text')
                        _buildTextMessage(context, content)
                      else if (messageType == 'image')
                        _buildImageMessage(context, message)
                      else if (messageType == 'file')
                        _buildFileMessage(context, message)
                      else if (messageType == 'location')
                        _buildLocationMessage(context, message)
                      else
                        _buildTextMessage(context, content),

                      // Read receipt for vendor messages
                      if (isFromVendor && isRead) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.done_all,
                              size: 12,
                              color: isFromVendor
                                  ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                                  : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.readStatus,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isFromVendor
                                    ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                                    : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                // Timestamp
                Padding(
                  padding: EdgeInsets.only(
                    left: isFromVendor ? 0 : 56,
                    right: isFromVendor ? 56 : 0,
                  ),
                  child: Text(
                    VendorChatState.formatMessageTime(createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isFromVendor) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.store,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextMessage(BuildContext context, String content) {
    return Text(
      content,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isFromVendor
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildImageMessage(BuildContext context, Map<String, dynamic> message) {
    final mediaUrl = message['media_url'] as String?;

    if (mediaUrl == null || mediaUrl.isEmpty) {
      return _buildTextMessage(context, AppStrings.imageNotAvailable);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            mediaUrl,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: isFromVendor
                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 32,
                      color: isFromVendor
                          ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.failedToLoadImage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isFromVendor
                            ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (message['content'] != null && message['content'].toString().isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildTextMessage(context, message['content'].toString()),
        ],
      ],
    );
  }

  Widget _buildFileMessage(BuildContext context, Map<String, dynamic> message) {
    final mediaUrl = message['media_url'] as String?;
    final fileName = message['content'] as String? ?? AppStrings.defaultDocumentName;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFromVendor
            ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.1)
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFromVendor
              ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.2)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_file,
            size: 20,
            color: isFromVendor
                ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isFromVendor
                        ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppStrings.tapToDownload,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isFromVendor
                        ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.5)
                        : Theme.of(context).colorScheme.outline,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMessage(BuildContext context, Map<String, dynamic> message) {
    final content = message['content'] as String? ?? AppStrings.defaultLocationContent;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFromVendor
            ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.1)
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFromVendor
              ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.2)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 20,
            color: isFromVendor
                ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isFromVendor
                    ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}