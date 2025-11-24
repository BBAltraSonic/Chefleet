import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../shared/widgets/glass_container.dart';
import '../blocs/chat_bloc.dart';
import '../widgets/chat_list_item.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(const LoadOrderChats());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Map<String, dynamic>> _filterOrderChats(List<Map<String, dynamic>> orderChats) {
    if (_searchQuery.isEmpty) return orderChats;

    return orderChats.where((orderChat) {
      // Search in vendor name (for buyers) or buyer name (for vendors)
      if (orderChat['vendor'] != null) {
        final vendor = orderChat['vendor'] as Map<String, dynamic>;
        final businessName = vendor['business_name'] as String? ?? '';
        return businessName.toLowerCase().contains(_searchQuery.toLowerCase());
      } else if (orderChat['buyer'] != null) {
        final buyer = orderChat['buyer'] as Map<String, dynamic>;
        final buyerName = buyer['full_name'] as String? ?? '';
        final buyerPhone = buyer['phone'] as String? ?? '';
        return buyerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            buyerPhone.contains(_searchQuery);
      }

      // Search in last message content
      final lastMessage = orderChat['last_message'] as Map<String, dynamic>?;
      if (lastMessage != null) {
        final content = lastMessage['content'] as String? ?? '';
        return content.toLowerCase().contains(_searchQuery.toLowerCase());
      }

      // Search in order ID
      final orderId = orderChat['id'] as String? ?? '';
      return orderId.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state.status == ChatStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == ChatStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load conversations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Unknown error occurred',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ChatBloc>().add(const LoadOrderChats());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final orderChats = _filterOrderChats(state.orderChats);

          return Column(
            children: [
              // Search bar
              Container(
                margin: const EdgeInsets.all(16),
                child: GlassContainer(
                  borderRadius: 12,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search conversations...',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              // Chat list
              Expanded(
                child: orderChats.isEmpty
                    ? _buildEmptyState(state)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: orderChats.length,
                        itemBuilder: (context, index) {
                          final orderChat = orderChats[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ChatListItem(
                              orderChat: orderChat,
                              onTap: () {
                                final orderId = orderChat['id'] as String;
                                final status = orderChat['status'] as String;
                                context.push('${CustomerRoutes.chat}/$orderId?orderStatus=$status');
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ChatState state) {
    final hasSearch = _searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'No conversations found' : 'No active conversations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Try adjusting your search terms'
                : 'Start a conversation by placing an order',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (!hasSearch) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to order placement or map screen
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.restaurant),
              label: const Text('Browse Dishes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

