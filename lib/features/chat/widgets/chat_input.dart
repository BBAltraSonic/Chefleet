import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../blocs/chat_bloc.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.orderId,
    required this.senderType,
    this.onAttachmentTap,
  });

  final String orderId;
  final String senderType;
  final VoidCallback? onAttachmentTap;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isComposing = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(SendMessage(
      orderId: widget.orderId,
      content: text,
      senderType: widget.senderType,
    ));

    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    _focusNode.unfocus();
  }

  void _handleTextChange(String text) {
    setState(() {
      _isComposing = text.trim().isNotEmpty;
    });

    // Check rate limit
    context.read<ChatBloc>().add(const CheckRateLimit());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        final isRateLimited = state.isRateLimited;
        final isSending = state.sendingMessages.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRateLimited)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 16,
                          color: Colors.red[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Slow down! You\'re sending messages too quickly.',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    // Attachment button
                    GlassContainer(
                      borderRadius: 24,
                      opacity: 0.1,
                      child: IconButton(
                        onPressed: isRateLimited || isSending
                            ? null
                            : widget.onAttachmentTap,
                        icon: Icon(
                          Icons.attach_file,
                          color: isRateLimited || isSending
                              ? Colors.grey
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Text input
                    Expanded(
                      child: GlassContainer(
                        borderRadius: 24,
                        opacity: 0.1,
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          onChanged: _handleTextChange,
                          enabled: !isRateLimited && !isSending,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _handleSend(),
                          decoration: InputDecoration(
                            hintText: isRateLimited
                                ? 'Please wait before sending...'
                                : 'Type a message...',
                            hintStyle: TextStyle(
                              color: isRateLimited
                                  ? Colors.grey
                                  : Colors.grey[600],
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
                    const SizedBox(width: 8),
                    // Send button
                    GlassContainer(
                      borderRadius: 24,
                      opacity: 0.2,
                      color: _isComposing && !isRateLimited && !isSending
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : null,
                      child: IconButton(
                        onPressed: (_isComposing && !isRateLimited && !isSending)
                            ? _handleSend
                            : null,
                        icon: isSending
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.send,
                                color: (_isComposing && !isRateLimited && !isSending)
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}