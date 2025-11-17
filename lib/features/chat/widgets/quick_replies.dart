import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../blocs/chat_bloc.dart';

class QuickReplies extends StatelessWidget {
  const QuickReplies({
    super.key,
    required this.orderId,
    required this.senderType,
    required this.replies,
  });

  final String orderId;
  final String senderType;
  final List<Map<String, dynamic>> replies;

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: replies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final reply = replies[index];
          return QuickReplyChip(
            content: reply['content'] as String,
            onTap: () {
              context.read<ChatBloc>().add(SendQuickReply(
                orderId: orderId,
                content: reply['content'] as String,
                senderType: senderType,
              ));
            },
          );
        },
      ),
    );
  }
}

class QuickReplyChip extends StatelessWidget {
  const QuickReplyChip({
    super.key,
    required this.content,
    required this.onTap,
  });

  final String content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 20,
      opacity: 0.1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// Vendor-specific quick replies
class VendorQuickReplies extends StatelessWidget {
  const VendorQuickReplies({
    super.key,
    required this.orderId,
    required this.orderStatus,
  });

  final String orderId;
  final String orderStatus;

  @override
  Widget build(BuildContext context) {
    final replies = _getQuickRepliesForStatus(orderStatus);

    return QuickReplies(
      orderId: orderId,
      senderType: 'vendor',
      replies: replies.map((content) => {'content': content}).toList(),
    );
  }

  List<String> _getQuickRepliesForStatus(String status) {
    switch (status) {
      case 'pending':
        return [
          'Thanks for your order! We\'ll start preparing it soon.',
          'How many people will be picking up?',
          'Any allergies or dietary restrictions?',
        ];
      case 'accepted':
        return [
          'Your order is being prepared now.',
          'It will be ready in about 15 minutes.',
          'Thanks for your patience!',
        ];
      case 'preparing':
        return [
          'Almost ready!',
          'Just 5 more minutes.',
          'We\'re adding the final touches.',
        ];
      case 'ready':
        return [
          'Your order is ready for pickup!',
          'Please provide your pickup code.',
          'Looking forward to seeing you!',
        ];
      default:
        return [
          'How can I help you?',
          'Thank you for your order!',
        ];
    }
  }
}

// Buyer-specific quick replies
class BuyerQuickReplies extends StatelessWidget {
  const BuyerQuickReplies({
    super.key,
    required this.orderId,
    required this.orderStatus,
  });

  final String orderId;
  final String orderStatus;

  @override
  Widget build(BuildContext context) {
    final replies = _getQuickRepliesForStatus(orderStatus);

    return QuickReplies(
      orderId: orderId,
      senderType: 'buyer',
      replies: replies.map((content) => {'content': content}).toList(),
    );
  }

  List<String> _getQuickRepliesForStatus(String status) {
    switch (status) {
      case 'pending':
        return [
          'When will my order be ready?',
          'Can I add something to my order?',
          'What are your hours?',
        ];
      case 'accepted':
        return [
          'Great! How long will it take?',
          'Can I change my pickup time?',
          'Thanks for accepting!',
        ];
      case 'preparing':
        return [
          'How much longer?',
          'I\'m on my way!',
          'Everything looks great!',
        ];
      case 'ready':
        return [
          'I\'m here for pickup!',
          'Here\'s my pickup code: ',
          'Thank you!',
        ];
      default:
        return [
          'Thank you!',
          'When should I arrive?',
        ];
    }
  }
}