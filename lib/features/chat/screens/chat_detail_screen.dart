import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../blocs/chat_bloc.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/quick_replies.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.orderId,
    required this.orderStatus,
  });

  final String orderId;
  final String orderStatus;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _scrollController = ScrollController();
  String _currentUserId = '';
  String _currentUserRole = '';

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _loadMessages();
    _subscribeToChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _unsubscribeFromChat();
    super.dispose();
  }

  void _initializeUser() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.id;
      // Get user role - this would typically come from user profile
      // For now, we'll determine it based on what we can access
      _determineUserRole();
    }
  }

  Future<void> _determineUserRole() async {
    try {
      // Try to get vendor record first
      final vendorResponse = await Supabase.instance.client
          .from('vendors')
          .select('id')
          .eq('owner_id', _currentUserId)
          .maybeSingle();

      setState(() {
        _currentUserRole = vendorResponse != null ? 'vendor' : 'buyer';
      });
    } catch (e) {
      setState(() {
        _currentUserRole = 'buyer';
      });
    }
  }

  void _loadMessages() {
    context.read<ChatBloc>().add(LoadChatMessages(orderId: widget.orderId));
  }

  void _subscribeToChat() {
    context.read<ChatBloc>().add(SubscribeToOrderChat(orderId: widget.orderId));
  }

  void _unsubscribeFromChat() {
    context.read<ChatBloc>().add(UnsubscribeFromOrderChat(orderId: widget.orderId));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${widget.orderId.substring(0, 8).toUpperCase()}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              _formatStatus(widget.orderStatus),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getStatusColor(widget.orderStatus),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _showOrderInfo(context);
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state.messagesStatus == ChatStatus.loaded) {
            _scrollToBottom();
          }
        },
        child: Column(
          children: [
            // Quick replies section
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (_currentUserRole == 'vendor') {
                  return VendorQuickReplies(
                    orderId: widget.orderId,
                    orderStatus: widget.orderStatus,
                  );
                } else {
                  return BuyerQuickReplies(
                    orderId: widget.orderId,
                    orderStatus: widget.orderStatus,
                  );
                }
              },
            ),
            // Messages list
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state.messagesStatus == ChatStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.messagesStatus == ChatStatus.error) {
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
                            'Failed to load messages',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.errorMessage ?? 'Unknown error',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _loadMessages,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return _buildEmptyChatState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isFromCurrentUser = message['sender_id'] == _currentUserId;
                      final senderType = message['sender_type'] as String? ?? 'unknown';

                      return ChatBubble(
                        message: message,
                        isFromCurrentUser: isFromCurrentUser,
                        senderType: senderType,
                      );
                    },
                  );
                },
              ),
            ),
            // Message input
            ChatInput(
              orderId: widget.orderId,
              senderType: _currentUserRole,
              onAttachmentTap: _handleAttachmentTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Start the conversation',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentUserRole == 'vendor'
                ? 'Send a message to coordinate with your customer'
                : 'Ask any questions about your order',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleAttachmentTap() {
    // TODO: Implement attachment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image attachments coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showOrderInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceGreen,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Order ID', widget.orderId),
              _buildInfoRow('Status', _formatStatus(widget.orderStatus)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready for pickup';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}