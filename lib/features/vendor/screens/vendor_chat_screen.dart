import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_strings.dart';

import '../blocs/vendor_chat_bloc.dart';
import '../widgets/conversation_list_widget.dart';
import '../widgets/conversation_skeleton_tile.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/quick_reply_widget.dart';
import '../widgets/chat_input_widget.dart';

class VendorChatScreen extends StatefulWidget {
  const VendorChatScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  State<VendorChatScreen> createState() => _VendorChatScreenState();
}

class _VendorChatScreenState extends State<VendorChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load conversations and quick replies
    context.read<VendorChatBloc>().add(LoadConversations());
    context.read<VendorChatBloc>().add(LoadQuickReplies());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.customerChat),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.chat),
              text: AppStrings.messages,
            ),
            Tab(
              icon: Icon(Icons.flash_on),
              text: AppStrings.quickReplies,
            ),
          ],
        ),
        actions: [
          BlocBuilder<VendorChatBloc, VendorChatState>(
            builder: (context, state) {
              final unreadCount = state.unreadConversations;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<VendorChatBloc>().add(
                        FilterConversations(hasUnreadOnly: true),
                      );
                    },
                    icon: const Icon(Icons.mark_chat_unread),
                    tooltip: AppStrings.unreadMessages,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMessagesTab(),
          _buildQuickRepliesTab(),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return BlocBuilder<VendorChatBloc, VendorChatState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.errorLoadingConversations,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'Unknown error occurred',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<VendorChatBloc>().add(LoadConversations());
                  },
                  child: const Text(AppStrings.tryAgain),
                ),
              ],
            ),
          );
        }

        if (state.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.noConversations,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.noConversationsHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        // Show chat interface
        if (state.currentConversationId != null) {
          return _buildChatInterface(state);
        }

        // Show conversation list
        return Column(
          children: [
            // Search Bar
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchConversations,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<VendorChatBloc>().add(
                              SearchConversations(query: ''),
                            );
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (query) {
                  context.read<VendorChatBloc>().add(SearchConversations(query: query));
                },
              ),
            ),

            // Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text(AppStrings.statusAll),
                    onSelected: (selected) {
                      if (selected) {
                        context.read<VendorChatBloc>().add(
                          FilterConversations(hasUnreadOnly: false),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text(AppStrings.statusUnread),
                    onSelected: (selected) {
                      if (selected) {
                        context.read<VendorChatBloc>().add(
                          FilterConversations(hasUnreadOnly: true),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // Conversation List
            Expanded(
              child: ConversationListWidget(
                conversations: state.filteredConversations,
                onConversationSelected: (conversationId) {
                  context.read<VendorChatBloc>().add(
                    LoadMessages(conversationId: conversationId),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChatInterface(VendorChatState state) {
    final conversation = state.conversations.firstWhere(
      (conv) => conv['id'] == state.currentConversationId,
      orElse: () => {},
    );

    return Column(
      children: [
        // Chat Header
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
              IconButton(
                onPressed: () {
                  setState(() {
                    // Reset to conversation list
                  });
                  context.read<VendorChatBloc>().add(LoadConversations());
                },
                icon: const Icon(Icons.arrow_back),
              ),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: VendorChatState.getCustomerAvatar(conversation).isNotEmpty
                    ? NetworkImage(VendorChatState.getCustomerAvatar(conversation))
                    : null,
                child: VendorChatState.getCustomerAvatar(conversation).isEmpty
                    ? Text(
                        VendorChatState.getConversationTitle(conversation)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      VendorChatState.getConversationTitle(conversation),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (VendorChatState.getCustomerPhone(conversation).isNotEmpty)
                      Text(
                        VendorChatState.getCustomerPhone(conversation),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // Call customer functionality
                },
                icon: const Icon(Icons.phone),
                tooltip: AppStrings.callCustomer,
              ),
            ],
          ),
        ),

        // Messages List
        Expanded(
          child: state.isMessagesLoading
              ? const Center(child: CircularProgressIndicator())
              : state.messages.isEmpty
                  ? const Center(
                      child: Text(AppStrings.noMessages),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        return ChatMessageWidget(
                          message: message,
                          isFromVendor: VendorChatState.isMessageFromVendor(message),
                        );
                      },
                    ),
        ),

        // Quick Replies Bar
        if (state.quickReplies.isNotEmpty)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.quickReplies.take(5).length,
              itemBuilder: (context, index) {
                final quickReply = QuickReply.fromJson(state.quickReplies[index]);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      quickReply.title,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      context.read<VendorChatBloc>().add(
                        SendQuickReply(
                          conversationId: state.currentConversationId!,
                          quickReply: quickReply,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

        // Message Input
        ChatInputWidget(
          conversationId: state.currentConversationId!,
          onSendMessage: (content, messageType, mediaUrl) {
            context.read<VendorChatBloc>().add(
              SendMessage(
                conversationId: state.currentConversationId!,
                content: content,
                messageType: messageType,
                mediaUrl: mediaUrl,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickRepliesTab() {
    return BlocBuilder<VendorChatBloc, VendorChatState>(
      builder: (context, state) {
        if (state.quickReplies.isEmpty) {
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
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showAddQuickReplyDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.addQuickReply),
                ),
              ],
            ),
          );
        }

        return QuickReplyWidget(
          quickReplies: state.quickReplies,
          groupedQuickReplies: state.groupedQuickReplies,
          onAddQuickReply: () => _showAddQuickReplyDialog(context),
          onEditQuickReply: (quickReply) => _showEditQuickReplyDialog(context, quickReply),
          onDeleteQuickReply: (quickReplyId) {
            context.read<VendorChatBloc>().add(
              DeleteQuickReply(quickReplyId: quickReplyId),
            );
          },
          onToggleQuickReply: (quickReplyId, isActive) {
            context.read<VendorChatBloc>().add(
              ToggleQuickReply(quickReplyId: quickReplyId, isActive: isActive),
            );
          },
        );
      },
    );
  }

  void _showAddQuickReplyDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = AppStrings.custom;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.addQuickReply),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: AppStrings.category,
                border: OutlineInputBorder(),
              ),
              items: VendorChatState.defaultCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                selectedCategory = value ?? AppStrings.custom;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: AppStrings.title,
                border: OutlineInputBorder(),
                hintText: AppStrings.titleHint,
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: AppStrings.message,
                border: OutlineInputBorder(),
                hintText: AppStrings.messageHint,
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty &&
                  contentController.text.trim().isNotEmpty) {
                context.read<VendorChatBloc>().add(
                  CreateQuickReply(
                    category: selectedCategory,
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text(AppStrings.add),
          ),
        ],
      ),
    );
  }

  void _showEditQuickReplyDialog(BuildContext context, Map<String, dynamic> quickReply) {
    final titleController = TextEditingController(text: quickReply['title']);
    final contentController = TextEditingController(text: quickReply['content']);
    String selectedCategory = quickReply['category'] ?? AppStrings.custom;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.editQuickReply),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: AppStrings.category,
                border: OutlineInputBorder(),
              ),
              items: VendorChatState.defaultCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                selectedCategory = value ?? AppStrings.custom;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: AppStrings.title,
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: AppStrings.message,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty &&
                  contentController.text.trim().isNotEmpty) {
                context.read<VendorChatBloc>().add(
                  UpdateQuickReply(
                    quickReplyId: quickReply['id'],
                    category: selectedCategory,
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text(AppStrings.update),
          ),
        ],
      ),
    );
  }
}